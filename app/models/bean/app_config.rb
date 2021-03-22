# frozen_string_literal: true
module Bean
  class AppConfig < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :application, class_name: "Bean::Application"

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods
    def format_ext_json
      {
        ext: {
          host: Rails.application.credentials.dig(Rails.env.to_sym, :host),
          appid: application.wechat_application.appid
        }
      }
    end
  end
end
