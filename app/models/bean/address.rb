# frozen_string_literal: true

module Bean
  class Address < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :user, optional: true
    belongs_to :country, class_name: "Bean::Country"
    belongs_to :province, class_name: "Bean::Province"
    belongs_to :city, class_name: "Bean::City"
    belongs_to :district, class_name: "Bean::District"

    # validation macros

    # callbacks
    before_save :update_other_is_default, if: :is_default_changed?

    # other macros
    delegate :name, to: :country, prefix: true, allow_nil: true
    delegate :name, to: :province, prefix: true, allow_nil: true
    delegate :name, to: :city, prefix: true, allow_nil: true
    delegate :name, to: :district, prefix: true, allow_nil: true

    # scopes

    # class methods

    # instance methods
    def human_address
      "#{country_name} #{province_name} #{city_name} + #{district_name} #{detail_info}"
    end

    def full_address
      "#{country_name} #{province_name} #{city_name} #{district_name} #{detail_info} + #{receiver_name} #{tel_number}"
    end

    private

    def update_other_is_default
      user.addresses.where.not(id: id).update_all(is_default: false) if is_default && user
    end
  end
end
