# frozen_string_literal: true

require "rails_helper"

RSpec.describe AppAPI::V1::Bean::Orders, type: :request do
  let(:application) { create(:application) }

  before do
    create(:store_role)
  end

  before(:each) do
    # ActiveStorage::Current.host返回的是nil，导致抛出exception，尚未找到解决办法
    ActiveStorage::Current.stub(:host).and_return("http://localhost:3000")
  end

  describe "GET /app_api/v1/bean/orders" do
    let(:user) { create(:user, application: application) }
    let(:merchant) { create(:merchant, application: application) }
    let(:store) { create(:store, merchant: merchant) }
    let(:token) { JsonWebToken.encode(user_id: user.id) }

    before do
      create(:order, user: user, store: store)

      get "/app_api/v1/bean/orders", headers: { "Authorization" => token }
    end

    it "response success" do
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body)).not_to eq([])
    end
  end

  describe "GET /app_api/v1/bean/orders/:id" do
    let(:user) { create(:user, application: application) }
    let(:merchant) { create(:merchant, application: application) }
    let(:store) { create(:store, merchant: merchant) }
    let(:token) { JsonWebToken.encode(user_id: user.id) }
    let(:order) { create(:order, user: user, store: store) }

    before do
      get "/app_api/v1/bean/orders/#{order.id}", headers: { "Authorization" => token }
    end

    it "response success" do
      expect(response.code).to eq("200")
      expect(JSON.parse(response.body)).not_to eq({})
    end
  end
end
