# frozen_string_literal: true

require "role_core/contrib/can_can_can_permission"

class CanCanCanPermission < RoleCore::CanCanCanPermission
  # read permission support block
  def call(context, *args)
    return unless callable

    subject = @subject || @model_name.constantize
    if block_attached?
      if @action == :read
        begin
          context.can @action, subject, @options.merge(@block.call(*args) || {})
        rescue TypeError
          raise "The block of #{@model_name} :read permission should return Hash data."
        end
      else
        context.can @action, subject, &@block.curry[*args]
      end
    else
      context.can @action, subject, @options
    end
  # rescue NameError
  #   raise "name '#{@model_name}' not valid. You must provide a valid model name."
  end
end
