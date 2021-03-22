# frozen_string_literal: true

class AttachPresenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, I18n.t("errors.messages.blank")) unless record.send(attribute).attached?
  end
end
