# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bean::ShoppingCartItem, type: :model do
  before do
    create(:store_role)
  end

  describe ".add_to_cart" do
    let(:application) { create(:application) }
    let(:merchant) { create(:merchant, application: application) }
    let(:store) { create(:store, merchant: merchant) }
    let(:product) { create(:product, name: "手机", merchant: merchant) }
    let(:variant) { create(:variant, product: product) }
    let(:store_variant) { create(:store_variant, store: store, variant: variant, is_active: is_active) }
    let(:shopping_cart) { create(:shopping_cart, user: user) }
    let(:user) { create(:user, application: application) }
    let(:is_active) { true }
    let(:stock_location) { create(:stock_location) }
    let(:count_on_hand) { 10 }
    let(:option_type) { create(:option_type, name: "内存", merchant: merchant) }
    let(:option_value) { create(:option_value, name: "16G", option_type: option_type) }

    before do
      create(:store_stock_location, store: store, stock_location: stock_location)
      create(:stock_location_item, stock_location: stock_location, variant: variant, count_on_hand: count_on_hand)

      create(:product_option_type, product: product, option_type: option_type)
      create(:option_value_variant, variant: variant, option_value: option_value)

      @cart_item = Bean::ShoppingCartItem.add_to_cart(shopping_cart: shopping_cart, store_variant_id: store_variant.id)
    end

    it "create cart item" do
      expect(@cart_item.new_record?).to eq(false)
    end

    context "when store variant is inactive" do
      let(:is_active) { false }

      it "not create cart item" do
        expect(@cart_item.errors.full_messages).to eq(["手机（内存：16G）无效"])
      end
    end

    context "when store variant is out of stock" do
      let(:count_on_hand) { 0 }

      it "not create cart item" do
        expect(@cart_item.errors.full_messages).to eq(["手机（内存：16G）库存不足"])
      end
    end
  end
end
