# frozen_string_literal: true

class Bean::CloseOrderJob < ApplicationJob
  def perform(order)
    order.perform_aasm_event!(:close) if order.may_close?
  end
end
