# frozen_string_literal: true

module Bean
  class Zone < ApplicationRecord
    # constants

    # concerns

    # attr related macros
    enum kind: {
      country: 0,
      province: 1
    }

    # association macros
    has_many :zone_members, class_name: "Bean::ZoneMember", dependent: :destroy

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
    def include?(address)
      return false unless address

      zone_members.any? do |zone_member|
        case zone_member.zoneable_type
        when "Bean::Country"
          zone_member.zoneable_id == address.country.id
        when "Bean::Province"
          zone_member.zoneable_id == address.province.id
        else
          false
        end
      end
    end
  end
end
