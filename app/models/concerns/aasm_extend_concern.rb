# frozen_string_literal: true

module AasmExtendConcern
  extend ActiveSupport::Concern

  def perform_aasm_event(event, error_msg: "当前状态不支持执行该操作！")
    begin
      perform_aasm_event!(event, error_msg: error_msg)
    # 数据被lock住，应该不会出现ActiveRecord::StatementInvalid错误了
    # rescue RuntimeError, ActiveRecord::StatementInvalid => e
    rescue RuntimeError => e
      errors.add(:base,  e.message)

      false
    end
  end

  def perform_aasm_event!(event, error_msg: "当前状态不支持执行该操作！")
    with_lock do
      raise error_msg unless send("may_#{event}?")

      db_and_redis_transaction do
        send("#{event}!")
      end

      true
    end
  end
end
