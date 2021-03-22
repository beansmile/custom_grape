# frozen_string_literal: true

module Bean
  module Stock
    module Splitter
      class ShippingTemplate < Bean::Stock::Splitter::Base

        # constants

        # concerns

        # attr related macros

        # association macros

        # validation macros

        # callbacks

        # other macros

        # scopes

        # class methods

        # instance methods

        def split(packages)
          split_packages = packages.flat_map(&method(:split_by_template))
          return_next(split_packages)
        end

        private

        def split_by_template(package)
          # group package items by shipping category
          grouped_packages = package.contents.group_by(&method(:shipping_template_for))
          hash_to_packages(grouped_packages)
        end

        def hash_to_packages(grouped_packages)
          # select values from packages grouped by shipping categories and build new packages
          grouped_packages.values.map(&method(:build_package))
        end

        # optimization: save variant -> shipping_category correspondence
        def shipping_template_for(item)
          @item_shipping_template ||= {}
          @item_shipping_template[item.inventory_unit.store_variant.variant_id] ||= item.store_variant.variant.product.shipping_template_id
        end
      end
    end
  end
end
