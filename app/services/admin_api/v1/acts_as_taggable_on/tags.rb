# frozen_string_literal: true
class AdminAPI::V1::ActsAsTaggableOn::Tags < API
  include Grape::Kaminari

  apis :index do
    helpers do
      params :index_params do
        optional :name_cont, type: String, desc: "name"
      end
    end
  end
end
