# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include CustomActiveStorageConcern

  # 手机号码格式
  MOBILE_PATTERN = /\A^1[3|4|5|6|7|8|9][0-9]{9}$\z/

  self.abstract_class = true

  def self.db_and_redis_transaction(&block)
    transaction do
      Sidekiq.redis do |redis|
        redis.multi do
          yield
        end
      end
    end
  end

  def db_and_redis_transaction(&block)
    self.class.db_and_redis_transaction(&block)
  end
end
