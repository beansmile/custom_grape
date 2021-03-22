# frozen_string_literal: true

module Bean
  module StoreVariantItemConcern
    extend ActiveSupport::Concern

    included do
      validate :check_store_variant, on: [:create, :preview]

      protected
      def check_store_variant
        unless store_variant.active?
          errors.add(:base, "#{store_variant.variant_name}无效")

          return
        end

        errors.add(:base, "#{store_variant.variant_name}库存不足") if store_variant.count_on_hand < quantity
      end
    end
  end
end
