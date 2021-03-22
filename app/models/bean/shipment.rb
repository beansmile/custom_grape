# frozen_string_literal: true

module Bean
  class Shipment < ApplicationRecord
    # constants

    # concerns
    include AASM
    include AasmExtendConcern

    # attr related macros
    enum state: {
      init: 0,
      pending: 1,
      shipped: 2,
      received: 3,
      cancelled: 4
    }

    # association macros
    belongs_to :order, class_name: "Bean::Order"
    belongs_to :address, class_name: "Bean::Address"
    belongs_to :stock_location, class_name: "Bean::StockLocation"
    belongs_to :shipping_category, class_name: "Bean::ShippingCategory", optional: true

    has_many :shipping_rates, class_name: "Bean::ShippingRate", dependent: :destroy
    has_many :inventory_units, class_name: "Bean::InventoryUnit", dependent: :restrict_with_error

    # validation macros
    validates :number, presence: true, uniqueness: true, on: :ship

    # callbacks

    # other macros
    aasm column: :state, enum: true, requires_lock: true  do
      state :init, initial: true
      state :pending
      state :shipped
      state :received
      state :cancelled

      event :suspend_ship do
        transitions from: :pending, to: :init
      end

      event :ready_to_ship do
        transitions from: :init, to: :pending
      end

      event :ship,
        after: [
          :update_shipped_at_and_change_order_to_shipped
        ],
        after_commit: [
          :enqueue_subscribe_express_service_notify_job
        ] do
        transitions from: :pending, to: :shipped
      end

      event :receive do
        transitions from: :shipped, to: :received
      end

      event :cancel do
        transitions from: :init, to: :cancelled
      end
    end

    ransacker :state, formatter: proc { |v| states[v] }

    # scopes

    # class methods

    # instance methods
    def human_address
      address.human_address
    end

    def ship(number:)
      begin
        with_lock do
          db_and_redis_transaction do
            assign_attributes(number: number)

            return false unless valid?(:ship)

            save!

            raise "该运单不可发货!" unless may_ship?

            ship!
          end
        end
      rescue RuntimeError => e
        errors.add(:base,  e.message)

        return false
      end

      true
    end

    def update_shipped_at_and_change_order_to_shipped
      update(shipped_at: Time.current)
      order.perform_aasm_event(:ship)
    end

    def enqueue_subscribe_express_service_notify_job
      Bean::SubscribeExpressServiceJob.perform_later(self)
    end
  end
end
