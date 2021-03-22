# frozen_string_literal: true

module Bean
  class Order < ApplicationRecord

    # constants
    AUTO_RECEIVE_TIME = 15.days
    CLOSE_ORDER_TIME = 15.minutes

    # concerns
    include AASM
    include AasmExtendConcern
    include Bean::NumberGenerator.new(prefix: "R", length: 18)
    include ExportXlsxConcern

    # attr related macros
    attr_accessor :ip_address

    enum state: {
      init: 0,
      completed: 1,
      applied: 2,
      refunding: 3,
      cancelled: 4,
      closed: 5
    }

    enum shipment_state: {
      init: 0,
      pending: 1,
      partial: 2,
      shipped: 3,
      cancelled: 4,
      received: 5
    }, _prefix: true

    enum order_source_type: {
      directly_buy: 0,
      shopping_cart: 1,
    }, _suffix: true


    delegate :merchant, to: :store, allow_nil: true

    # association macros
    belongs_to :user
    belongs_to :store, class_name: "Bean::Store", optional: true
    belongs_to :address, class_name: "Bean::Address", optional: true

    has_many :line_items, class_name: "Bean::LineItem", dependent: :destroy
    accepts_nested_attributes_for :line_items, allow_destroy: true
    has_many :payments, class_name: "Bean::Payment", as: :paymentable, dependent: :destroy
    has_many :all_payments, class_name: "Bean::Payment", foreign_key: :order_id, dependent: :destroy
    has_many :adjustments, class_name: "Bean::Adjustment", as: :adjustable, dependent: :destroy
    has_many :all_adjustments, class_name: "Bean::Adjustment", foreign_key: :order_id, dependent: :destroy, inverse_of: :order
    has_many :shipments, class_name: "Bean::Shipment", dependent: :destroy
    has_many :inventory_units, class_name: "Bean::InventoryUnit", dependent: :destroy
    has_many :after_sales, class_name: "Bean::AfterSale", dependent: :destroy

    # validation macros
    validates :address, presence: true, on: [:create, :update]
    validate :check_address, on: [:preview], if: :address
    validate :check_store, on: [:create, :update, :preview]

    # callbacks
    after_create_commit :enqueue_close_order_job

    # other macros
    aasm column: :state, enum: true, requires_lock: true  do
      state :init, initial: true
      state :completed
      state :applied
      state :refunding
      state :cancelled
      state :closed

      event :close, after: [:increment_inventory, :close_all_pending_payments!, :cancel_ship!] do
        transitions from: :init, to: :closed
      end

      event :pay do
        transitions from: :init, to: :completed,
                    after: [
                      :set_completed_at,
                      :ready_to_ship!,
                      :increment_sales_volume
                    ]
      end

      event :apply_refund, after: [:suspend_ship!] do
        transitions from: :completed, to: :applied,
                    guard: :may_suspend_ship?
      end

      event :refund, after: [:suspend_ship!], after_commit: [:enqueue_refund_order_job] do
        transitions from: :completed,
                    to: :refunding,
                    guard: :may_suspend_ship?
      end

      event :agree_refund, after_commit: [:enqueue_refund_order_job] do
        transitions from: :applied, to: :refunding
      end

      event :refuse_refund, after: [:ready_to_ship!] do
        transitions from: :applied,
                    to: :completed
      end

      event :cancel, guard: :refunded_all_amount?, after: [:increment_inventory, :decrement_sales_volume, :cancel_ship!] do
        transitions from: :refunding, to: :cancelled
      end
    end

    aasm :shipment_state_machine, column: :shipment_state, enum: true, requires_lock: true  do
      state :init, initial: true
      state :pending
      state :partial
      state :shipped
      state :cancelled
      state :received

      event :suspend_ship, after: [:all_shipments_suspend_ship]  do
        transitions from: :pending, to: :init
      end

      event :ready_to_ship, after: [:all_shipments_ready_to_ship] do
        transitions from: :init, to: :pending
      end

      event :ship, after_commit: [:enqueue_auto_receive_job] do
        transitions from: [:pending, :partial], to: :shipped, guards: [:all_shipments_shipped?]
        transitions from: :pending, to: :partial
      end

      event :receive, after: [:change_all_shipped_shipments_to_received, :set_received_at] do
        transitions from: :shipped, to: :received
      end

      event :cancel_ship, after: [:cancel_all_shipments] do
        transitions from: :init, to: :cancelled
      end
    end

    ransacker :state, formatter: proc { |v| states[v]}
    ransacker :shipment_state, formatter: proc { |v| shipment_states[v]}

    # scopes
    scope :today, -> { where(arel_table[:created_at].gteq(Time.current.midnight)) }
    scope :recent_day, -> (day) { where(arel_table[:created_at].gteq((Time.current - day.day).midnight)) }

    # class methods

    # instance methods
    def refunded_all_amount?
      total == refund_amount
    end

    def refund_payments!
      db_and_redis_transaction do
        payments.charge_payment_type.completed.each do |payment|
          payment.enqueue_refund_job
        end
      end
    end

    def apply_refund(apply_reason: nil)
      begin
        with_lock do
          db_and_redis_transaction do
            update!(apply_reason: apply_reason)

            raise "该订单不能申请退款！" unless may_apply_refund?

            apply_refund!
          end
        end
      rescue RuntimeError => e
        errors.add(:base,  e.message)

        return false
      end

      true
    end

    def all_shipments_shipped?
      !shipments.any? { |shipment| shipment.state.in?(["init", "pending"]) }
    end

    def change_all_shipped_shipments_to_received
      shipments.shipped.each { |shipment| shipment.perform_aasm_event!(:receive) }
    end

    def cancel_all_shipments
      shipments.each { |shipment| shipment.perform_aasm_event!(:cancel) }
    end

    def close_all_pending_payments!
      payments.charge_payment_type.pending.each { |payment| payment.perform_aasm_event!(:close_charge) }
    end

    def change_all_shipments_to_init
      shipments.each(&:init!)
    end

    def generate
      begin
        transaction do
          return false unless valid?

          assign_data

          address.save!

          save!

          decrement_inventory
          # 清理购物车
          user.shopping_cart.shopping_cart_items.where(store_variant_id: line_items.map(&:store_variant_id)).destroy_all if shopping_cart_order_source_type?
        end
      # 数据库加了约束，stock_location_items的count_on_hand不能小于0
      rescue ActiveRecord::StatementInvalid
        errors.add(:base, "#{StoreVariant.model_name.human}库存不足")

        return false
      end

      true
    end

    def preview
      valid?(:preview)

      assign_data

      true
    end

    def auto_close_at
      (init? && persisted?) ? created_at + CLOSE_ORDER_TIME : nil
    end

    def assign_data
      self.store_id = line_items.first.store_id

      line_items.each do |line_item|
        store_variant = line_item.store_variant
        line_item.price = store_variant.cost_price
        line_item.product_name = store_variant.product_name
        line_item.image = store_variant.product_images.first.signed_id
        line_item.option_types = store_variant.option_values.map do |option_value|
          {
            name: option_value.option_type.name,
            value: option_value.name
          }
        end
      end

      self.item_total = line_items.sum { |line_item| line_item.store_variant.cost_price * line_item.quantity }
      self.shipment_total = 0

      if address
        dup_address = self.address.dup
        dup_address.user_id = nil
        self.address = dup_address

        self.shipments = Bean::Stock::Coordinator.new(self).shipments.each do |shipment|
          shipping_rate = shipment.shipping_rates.detect(&:selected?)
          shipping_category = shipping_rate.shipping_method.shipping_category

          shipment.cost = shipping_rate.cost
          shipment.shipping_category = shipping_category
          shipment.shipping_method_name = "#{shipping_category.name}（#{shipping_category.shipping_template.name}）"
        end

        self.shipment_total = shipments.sum(&:cost)

        if item_total >= merchant.free_freight_amount
          all_adjustments.build(adjustable: self, amount: - shipment_total, label: "免邮", source: self)
        end
      end

      self.adjustment_total = all_adjustments.sum(:amount)
      self.total = item_total + shipment_total + adjustment_total
    end

    def increment_inventory
      inventory_units.each do |inventory_unit|
        inventory_unit.shipment.stock_location.stock_location_items.find_by(variant_id: inventory_unit.store_variant.variant_id).increment!(:count_on_hand, inventory_unit.quantity)
      end
    end

    def decrement_inventory
      inventory_units.each do |inventory_unit|
        inventory_unit.shipment.stock_location.stock_location_items.find_by(variant_id: inventory_unit.store_variant.variant_id).decrement!(:count_on_hand, inventory_unit.quantity)
      end
    end

    def increment_sales_volume
      line_items.each do |line_item|
        line_item.store_variant.increment!(:sales_volume, line_item.quantity)
      end
    end

    def decrement_sales_volume
      line_items.each do |line_item|
        line_item.store_variant.decrement!(:sales_volume, line_item.quantity)
      end
    end

    def export_data
      # export_data_with %w(user number state shipment_state item_total shipment_total promo_total adjustment_total refund_amount
                          # total line_items created_at completed_at user_remark admin_user_remark address apply_reason order_source_type)

      # 暂无promo_total和adjustment_total
      export_data_with %w(user number state shipment_state item_total shipment_total refund_amount
                          total line_items created_at completed_at user_remark admin_user_remark address apply_reason order_source_type)
    end

    def export_data_with(columns)
      [
        column("user") { user.screen_name },
        column("number"),
        column("state") { Bean::Order.human_attribute_name("states.#{state}") },
        column("shipment_state") { Bean::Order.human_attribute_name("shipment_states.#{shipment_state}") },
        column("item_total"),
        column("shipment_total"),
        column("promo_total"),
        column("adjustment_total"),
        column("refund_amount"),
        column("total"),
        column("line_items") { line_items.map { |l| [l.store_variant.variant.name, l.quantity, l.store_variant.cost_price].join(",") }.join("\n") },
        column("created_at") { created_at && I18n.l(created_at, format: :long) },
        column("completed_at") { completed_at && I18n.l(completed_at, format: :long) },
        column("user_remark"),
        column("admin_user_remark"),
        column("address") { address.full_address },
        column("apply_reason"),
        column("order_source_type") { Bean::Order.human_attribute_name("order_source_type.#{order_source_type}") }
      ].select { |column| column[:name].in?(columns) }
    end

    def auto_receive_at
      shipment_state_shipped? ? shipments.order(:shipped_at).last.shipped_at + AUTO_RECEIVE_TIME : nil
    end

    protected
    def enqueue_close_order_job
      Bean::CloseOrderJob.set(wait_until: auto_close_at).perform_later(self)
    end

    def check_store
      errors.add(:base, "不支持同时购买不同#{Bean::Store.model_name.human}的商品") if line_items.map(&:store_id).uniq.count > 1
    end

    def check_address
      errors.add(:base, "请选择正确的#{Bean::Order.human_attribute_name(:address)}") unless user.addresses.exists?(id: address_id)
    end

    def set_completed_at
      update completed_at: Time.current
    end

    def all_shipments_ready_to_ship
      shipments.each(&:ready_to_ship!)
    end

    def all_shipments_suspend_ship
      shipments.each(&:suspend_ship!)
    end

    def set_received_at
      update(received_at: Time.current)
    end

    def enqueue_auto_receive_job
      Bean::AutoReceiveOrderJob.set(wait_until: auto_receive_at).perform_later(self) if shipment_state_shipped?
    end

    def enqueue_refund_order_job
      Bean::RefundOrderJob.perform_later(self)
    end
  end
end
