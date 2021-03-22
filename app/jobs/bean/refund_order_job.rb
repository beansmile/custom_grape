# frozen_string_literal: true

class Bean::RefundOrderJob < ApplicationJob
  def perform(order)
    order.refund_payments!
  end
end
