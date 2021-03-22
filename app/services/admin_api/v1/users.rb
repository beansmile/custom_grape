# frozen_string_literal: true
class AdminAPI::V1::Users < API
  include Grape::Kaminari

  apis [:index, :show] do
    helpers do
      params :index_params do
        optional :screen_name_cont
        optional :profile_phone_cont
      end
    end
  end
end
