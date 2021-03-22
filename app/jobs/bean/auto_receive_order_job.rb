# frozen_string_literal: true

class Bean::AutoReceiveOrderJob < ApplicationJob
  def perform(order)
    order.perform_aasm_event!(:receive) if order.may_receive?
  end
end
