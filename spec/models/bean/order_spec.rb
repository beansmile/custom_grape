# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bean::Order, type: :model do
  before do
    create(:store_role)
  end

  describe "#generate" do
    let(:application) { create(:application) }
    let(:user) { create(:user, application: application) }
    let(:merchant) { create(:merchant, free_freight_amount: 5) }
    let(:store) { create(:store, merchant: merchant) }
    let(:shipping_template) { create(:shipping_template, merchant: merchant, calculate_type: :weight) }
    let(:shipping_category) { create(:shipping_category, shipping_template: shipping_template) }
    let(:shipping_method) { create(:shipping_method, shipping_category: shipping_category, is_default: true) }
    let(:product) { create(:product, merchant: merchant, shipping_template: shipping_template) }
    let(:variant) { create(:variant, product: product, weight: 1, track_inventory: true) }
    let(:store_variant) { create(:store_variant, store: store, variant: variant, cost_price: 10) }
    let(:line_items_attributes) do
      [
        {
          quantity: 1,
          store_variant_id: store_variant.id
        }
      ]
    end
    let(:address) { create(:address, user: user) }
    let(:stock_location) { create(:stock_location, is_active: true) }

    before do
      create(:store_stock_location, store: store, stock_location: stock_location)
      @stock_location_item = create(:stock_location_item, stock_location: stock_location, variant: variant, count_on_hand: 999)

      create(:calculator_shipping_weight, calculable: shipping_method)

      @order = Bean::Order.new(user: user, address_id: address.id, line_items_attributes: line_items_attributes)
      @order.generate

      @stock_location_item.reload
    end

    it "generate order" do
      expect(@order.persisted?).to eq(true)
    end

    it "decrement count on hand" do
      expect(@stock_location_item.count_on_hand).to eq(998)
    end
  end

  describe "#preview" do
    let(:application) { create(:application) }
    let(:user) { create(:user, application: application) }
    let(:merchant) { create(:merchant, free_freight_amount: 5) }
    let(:store) { create(:store, merchant: merchant) }
    let(:shipping_template) { create(:shipping_template, merchant: merchant, calculate_type: :weight) }
    let(:shipping_category) { create(:shipping_category, shipping_template: shipping_template) }
    let(:shipping_method) { create(:shipping_method, shipping_category: shipping_category, is_default: true) }
    let(:product) { create(:product, name: "手机", merchant: merchant, shipping_template: shipping_template) }
    let(:variant_1) { create(:variant, product: product, weight: 1, track_inventory: true) }
    let(:variant_2) { create(:variant, product: product, weight: 2, track_inventory: true) }
    let(:store_variant_1) { create(:store_variant, store: store, variant: variant_1, cost_price: 10, origin_price: 11) }
    let(:store_variant_2) { create(:store_variant, store: store, variant: variant_2, cost_price: 8, origin_price: 9) }
    let(:line_items_attributes) do
      [
        {
          quantity: 1,
          store_variant_id: store_variant_1.id
        }, {
          quantity: 2,
          store_variant_id: store_variant_2.id
        }
      ]
    end
    let(:address) { nil }
    let(:stock_location) { create(:stock_location, is_active: true) }
    let(:option_type) { create(:option_type, name: "内存", merchant: merchant) }
    let(:option_value_1) { create(:option_value, name: "16G", option_type: option_type) }
    let(:option_value_2) { create(:option_value, name: "32G", option_type: option_type) }

    before do
      create(:product_option_type, product: product, option_type: option_type)
      create(:option_value_variant, variant: variant_1, option_value: option_value_1)
      create(:option_value_variant, variant: variant_2, option_value: option_value_2)

      create(:store_stock_location, store: store, stock_location: stock_location)
      create(:stock_location_item, stock_location: stock_location, variant: variant_1, count_on_hand: 999)
      create(:stock_location_item, stock_location: stock_location, variant: variant_2, count_on_hand: 999)

      create(:calculator_shipping_weight, calculable: shipping_method, preferences: { first_weight: "1", first_weight_price: "6", continued_weight: "1", continued_weight_price: "1" })

      @order = Bean::Order.new(user: user, address_id: address&.id, line_items_attributes: line_items_attributes)
      @order.preview
    end

    it "assign basic data" do
      expect(@order.total).to eq(26)
      expect(@order.item_total).to eq(26)
      expect(@order.shipment_total).to eq(0)
    end

    it "assign line items data" do
      line_item_1 = @order.line_items.detect { |line_item| line_item.store_variant_id == store_variant_1.id }
      line_item_2 = @order.line_items.detect { |line_item| line_item.store_variant_id == store_variant_2.id }

      expect(line_item_1.product_name).to eq("手机")
      expect(line_item_1.quantity).to eq(1)
      expect(line_item_1.price).to eq(10)
      expect(line_item_1.option_types).to eq([{ "name" => "内存", "value" => "16G" }])

      expect(line_item_2.product_name).to eq("手机")
      expect(line_item_2.quantity).to eq(2)
      expect(line_item_2.price).to eq(8)
      expect(line_item_2.option_types).to eq([{ "name" => "内存", "value" => "32G" }])
    end

    context "when has address" do
      let(:address) { create(:address, user: user) }

      it "assign basic data" do
        expect(@order.shipment_total).to eq(10)
      end

      it "assign shipment data" do
        shipment = @order.shipments[0]

        expect(shipment.cost).to eq(10)
      end

      it "assign shipping rates data" do
        shipping_rate = @order.shipments[0].shipping_rates[0]

        expect(shipping_rate.cost).to eq(10)
        expect(shipping_rate.selected?).to eq(true)
      end

      it "assign inventory units data" do
        shipment = @order.shipments[0]

        inventory_unit_1 = shipment.inventory_units.detect { |unit| unit.store_variant == store_variant_1 }
        inventory_unit_2 = shipment.inventory_units.detect { |unit| unit.store_variant == store_variant_2 }

        expect(inventory_unit_1.quantity).to eq(1)
        expect(inventory_unit_2.quantity).to eq(2)
      end
    end
  end

  describe "#close!" do
    let(:order) { create(:order) }

    before do
      line_item = order.line_items.first
      shipment = order.shipments.first

      create(:stock_location_item, variant: line_item.store_variant.variant, stock_location: shipment.stock_location)
    end

    it "update order state" do
      order.close!

      expect(order.closed?).to eq(true)
    end

    context "when order has payment" do
      let(:resp_data) do
        {
          "return_code"=>"SUCCESS",
          "return_msg"=>"OK",
          "appid"=>"wx93bf3795383fxxxx",
          "mch_id"=>"1596934xxx",
          "sub_mch_id"=>"",
          "nonce_str"=>"6Ok2QF4QINO0aGTy",
          "sign"=>"F746809E2204E10A03B308C1B6E7A44B",
          "result_code"=>"SUCCESS"
        }
      end

      before do
        @payment = create(:payment, order: order)

        WxPay::Service.stub(:invoke_closeorder).and_return({ :raw => { "xml"=> resp_data } }.merge(resp_data))
      end

      it "update payment state" do
        order.close!
        @payment.reload

        expect(@payment.closed?).to eq(true)
      end

      context "and payment already paid" do
        let(:resp_data) do
          {
            "return_code"=>"SUCCESS",
            "return_msg"=>"OK",
            "appid"=>"wx93bf3795383fxxxx",
            "mch_id"=>"1596934xxx",
            "sub_mch_id"=>"",
            "nonce_str"=>"EUti3GDIV5ZDQV0G",
            "sign"=>"23B39AC837D34C018E24B8BAD4D17272",
            "result_code"=>"FAIL",
            "err_code"=>"ORDERPAID",
            "err_code_des"=>"order paid"
          }
        end

        before do
          order.perform_aasm_event(:close)

          @payment.reload
        end

        it "not update order state" do
          expect(order.closed?).to eq(true)
          expect(order.errors.full_messages).to eq(["订单已支付"])
        end

        it "not update payment state" do
          expect(@payment.pending?).to eq(true)
        end
      end
    end
  end

  describe "#receive!" do
    let(:order) { create(:shipped_order) }

    before do
      order.receive!
    end

    it "update shipment state" do
      expect(order.received?).to eq(true)
    end

    it "update order state" do
      expect(order.shipments.first.received?).to eq(true)
    end
  end

  describe "#apply_refund!" do
    let(:order) { create(:completed_order) }

    before do
      order.apply_refund!
    end

    it "update order shipment state" do
      expect(order.shipment_state_init?).to eq(true)
    end

    it "update shipment state" do
      expect(order.shipments.first.init?).to eq(true)
    end
  end

  describe "#refuse_refund!" do
    let(:order) { create(:apply_refund_order) }

    before do
      order.refuse_refund!
    end

    it "update order shipment state" do
      expect(order.shipment_state_pending?).to eq(true)
    end

    it "update shipment state" do
      expect(order.shipments.first.pending?).to eq(true)
    end
  end

  describe "#agree_refund!" do
    let(:order) { create(:apply_refund_order) }

    before do
      order.agree_refund!
    end

    it "update order state" do
      expect(order.refunding?).to eq(true)
    end

    it "enqueue refund order job" do
      expect(Bean::RefundOrderJob).to have_been_enqueued.with(order)
    end
  end

  describe "#refund!" do
    let(:order) { create(:completed_order) }

    before do
      order.refund!
    end

    it "update order state" do
      expect(order.refunding?).to eq(true)
      expect(order.shipment_state_init?).to eq(true)
    end

    it "update shipment state" do
      expect(order.shipments.first.init?).to eq(true)
    end

    it "enqueue refund order job" do
      expect(Bean::RefundOrderJob).to have_been_enqueued.with(order)
    end
  end
end
