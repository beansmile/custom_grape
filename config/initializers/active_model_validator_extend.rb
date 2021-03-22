# frozen_string_literal: true

module ActiveModel
  module Validations
    class AssociatedValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if Array(value).reject { |r| valid_object?(r) }.any?
          record.errors.add(attribute, :invalid, **options.merge(value: value))
        end
      end

      private

      def valid_object?(record)
        record.valid?
      end
    end

    module ClassMethods
      def validates_associated(*attr_names)
        validates_with AssociatedValidator, _merge_attributes(attr_names)
      end
    end
  end
end
