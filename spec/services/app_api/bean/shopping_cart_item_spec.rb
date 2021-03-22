# frozen_string_literal: true

require "rails_helper"

RSpec.describe AppAPI::V1::Bean::ShoppingCartItemGroups, type: :request do
  let(:application) { create(:application) }

  before(:each) do
    # ActiveStorage::Current.host返回的是nil，导致抛出exception，尚未找到解决办法
    ActiveStorage::Current.stub(:host).and_return("http://localhost:3000")
    create(:store_role)
  end

  describe "GET /app_api/v1/bean/shopping_cart_item_groups" do
    let(:merchant) { create(:merchant, application: application) }
    let(:store) { create(:store, merchant: merchant) }
    let(:user) { create(:user) }
    let(:token) { JsonWebToken.encode(user_id: user.id) }

    before do
      create(:shopping_cart_item, shopping_cart: user.shopping_cart)

      get "/app_api/v1/bean/shopping_cart_item_groups", headers: { "Authorization" => token }
    end

    it "response success" do
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body)).not_to eq([])
    end
  end
end
