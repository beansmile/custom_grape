# frozen_string_literal: true

module SettingActiveStorageConcern
  extend ActiveSupport::Concern

  include CustomActiveStorageConcern

  def self.included(klass)
    klass.instance_eval do
      has_one_attached :attachment
      custom_has_many_attached :attachments

      before_save :set_attachment

      def self.attachment_fields(*field_attrs)
        field_attrs.map(&:to_s).each do |field_attr|
          define_method "expose_#{field_attr}" do
            # 根据filed类型判断使用attachment还是attachments
            if value.class == Array
              attachments.map do |attachment|
                blob_data(attachment)
              end
            else
              blob_data(attachment.attached? ? attachment : nil)
            end
          end
        end
      end
    end
  end

  # field value存放blob的signed_id
  def set_attachment
    if is_attachment_field?
      value.class == Array ? self.attachments = value : self.attachment = value
    end
  end

  def blob_data(attachment)
    {
      url: attachment&.service_url,
      signed_id: attachment&.signed_id,
      content_type: attachment&.content_type,
      filename: attachment&.filename
    }
  end

  def is_attachment_field?
    respond_to? "expose_#{var}"
  end

  def expose_attachment
    public_send "expose_#{var}"
  end
end
