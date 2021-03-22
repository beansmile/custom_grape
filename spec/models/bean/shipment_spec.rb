# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bean::Shipment, type: :model do
  before do
    create(:store_role)
  end

  describe "#ship" do
    let(:order) { create(:completed_order) }

    before do
      @shipment = order.shipments.first
    end

    it "change shipment state" do
      @shipment.ship(number: "123")

      expect(@shipment.shipped?).to eq(true)
    end

    it "change order shipment state" do
      @shipment.ship(number: "123")

      expect(@shipment.order.shipment_state_shipped?).to eq(true)
    end

    it "enqueue auto receive job" do
      @shipment.ship(number: "123")

      expect(Bean::AutoReceiveOrderJob).to have_been_enqueued.with(order)
    end

    context "when order has two shipment" do
      let(:other_stock_location) { create(:stock_location) }
      let(:other_shipment_state) { :pending }
      let(:other_shipment_shipped_at ) { nil }

      before do
        create(:shipment, stock_location: other_stock_location, order: order, address: order.address, state: other_shipment_state, shipped_at: other_shipment_shipped_at)

        @shipment.ship(number: "1234")
      end

      it "change order shipment state" do
        expect(@shipment.order.shipment_state_partial?).to eq(true)
      end

      context "and other shipment state is shipped" do
        let(:other_shipment_state) { :shipped }
        let(:other_shipment_shipped_at ) { Time.current }

        it "change order shipment state" do
          expect(@shipment.order.shipment_state_shipped?).to eq(true)
        end
      end
    end
  end
end
