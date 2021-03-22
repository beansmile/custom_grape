# frozen_string_literal: true

class VerificationCode
  MOBILE_PATTERN = /\A^1[3|4|5|6|7|8|9][0-9]{9}$\z/
  EMAIL_PATTERN = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  EXPIRATION = 10.minutes
  MOBILE_EXPIRATION = 3.minutes
  SEND_INTERVAL = 1.minute
  RETRY_TIMES = 10
  include Redis::Objects

  attr_reader :target, :event

  value :code_in_redis, expiration: EXPIRATION
  value :sent_at, expiration: EXPIRATION, marshal: true
  counter :retry_times, expiration: EXPIRATION

  MESSAGE = {
    reset_password: "重置密码",
    sign_up: "注册",
  }

  def self.is_email?(target)
    target.include?("@")
  end

  def initialize(target, event)
    # 邮箱大小写不敏感
    @target = target.downcase
    @event = event
  end

  def send_code
    self.code = rand.to_s[2..7]
    sent_at.set(Time.current)
    retry_times.set(0)

    if is_email?
      send_email
    else
      send_sms
    end
  end

  def is_email?
    VerificationCode.is_email?(target)
  end

  def send_sms
    # TODO 目前没有短信服务
    message = {
      sign_up: "温馨提示：请不要将验证码告知他人。您的注册验证码是#{code}。该验证码将在3分钟后失效。"
    }[event.to_sym]

    message = "#{message}【签名】"

    SendSmsJob.perform_later(target, message)
  end

  def send_email
    title = "#{MESSAGE[event.to_sym]}验证码"
    VerificationMailer.with(target: target, title: title, code: code).send_code.deliver_later
  end

  def can_send_again?
    Time.current - sent_at.get >= SEND_INTERVAL
  end

  def code
    @code ||= code_in_redis.get
  end

  def code=(code)
    @code = code
    code_in_redis.set(code)
  end

  def id
    "#{target}_#{event}"
  end

  def verify(params_code)
    if retry_times <= RETRY_TIMES && code == params_code && (is_email? ? true : (Time.current - sent_at.get <= MOBILE_EXPIRATION))
      true
    else
      retry_times.increment

      false
    end
  end

  def clean
    code_in_redis.del
    sent_at.del
    retry_times.del
  end

  class << self
    def verify(target, event, params_code)
      new(target, event).verify(params_code)
    end

    MESSAGE.keys.each do |event|
      define_method "build_#{event}_object" do |target|
        new(target, event)
      end
    end
  end
end
