# frozen_string_literal: true

module ExportXlsxConcern
  extend ActiveSupport::Concern

  def column(name, options = { width: 12 }, &block)
    {
      name: name,
      value: block_given? ? block.call : public_send(name),
      width: options[:width],
      type: options[:type] || :string
    }
  end
end
