# frozen_string_literal: true

module Helpers
  module BaseHelper
    def session
      env["rack.session"]
    end

    def response_success(message = "OK", options = {})
      { code: 200, message: message }.merge(options)
    end

    def response_error(message = "error", code = 400)
      error!({code: "#{code}00".to_i, detail: {}, error_message: message }, code)
    end

    def response_record_error(object)
      response_error(object.errors.full_messages.join(","))
    end

    def ip_address
      (request.env["action_dispatch.remote_ip"] || request.ip).to_s
    end

    def standard_update(object, params, entities, entities_options = {})
      if object.update(params)
        present object, { with: entities }.merge(entities_options)
      else
        response_record_error(object)
      end
    end

    def standard_save(object, entities, entities_options = {})
      if object.save
        present object, {with: entities}.merge(entities_options)
      else
        response_record_error(object)
      end
    end

    def standard_destroy(object)
      if object.destroy
        response_success
      else
        response_record_error(object)
      end
    end
  end
end
