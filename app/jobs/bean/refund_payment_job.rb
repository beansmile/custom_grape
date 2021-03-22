# frozen_string_literal: true

class Bean::RefundPaymentJob < ApplicationJob
  def perform(payment)
    payment.refund!
  end
end
