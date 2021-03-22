# frozen_string_literal: true

module Bean
  class AfterSale < ApplicationRecord
    # constants
    include ExportXlsxConcern

    # concerns

    # attr related macros
    enum state: {
      init: 0,
      pending: 1,
      shipped: 2,
      refused: 3,
      refunding: 4,
      completed: 5,
      closed: 6
    }

    enum after_sale_type: {
      refund: 0,
      sale_refund: 1
    }, _prefix: true

    # association macros
    belongs_to :user
    belongs_to :order, class_name: "Bean::Order"
    belongs_to :store, class_name: "Bean::Store"

    has_many :payments, class_name: "Bean::Payment", as: :paymentable, dependent: :destroy
    has_many :after_sale_items, class_name: "Bean::AfterSaleItem", dependent: :destroy

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
    def export_data
      export_data_with %w(user order number state after_sale_type agreed_at reason amount reject_reason after_sale_items created_at)
    end

    def export_data_with(columns)
      [
        column("user") { user.screen_name },
        column("order") { order.number },
        column("number"),
        column("state") { Bean::AfterSale.human_attribute_name("states.#{state}") },
        column("after_sale_type") { Bean::AfterSale.human_attribute_name("after_sale_types.#{after_sale_type}") },
        column("agreed_at"),
        column("reason"),
        column("amount"),
        column("reject_reason"),
        column("after_sale_items") { after_sale_items.map { |a| a.line_item.store_variant.variant.name}.join("\n") },
        column("created_at") { created_at && I18n.l(created_at, format: :long) },
      ].select { |column| column[:name].in?(columns) }
    end
  end
end
