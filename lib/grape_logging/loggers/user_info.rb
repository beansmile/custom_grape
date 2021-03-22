# frozen_string_literal: true
module GrapeLogging
  module Loggers
    class UserInfo < GrapeLogging::Loggers::Base
      def parameters(request, _)
        token = request.env["HTTP_AUTHORIZATION"]

        return {} if token.blank?

        { user_info: { authorization: (JsonWebToken.decode(token) rescue nil) } }
      end
    end
  end
end
