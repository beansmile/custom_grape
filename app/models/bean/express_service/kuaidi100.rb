# frozen_string_literal: true

module Bean
  class ExpressService::Kuaidi100 < ExpressService

    ["key" ,"customer", "salt"].each do |p_attr|
      define_method p_attr do
        @p_attr = configs[p_attr]
      end
    end

    def client
      return nil if key.nil? || customer.nil? || salt.nil?
      @client ||= ::Kuaidi100::Client.new({
        key: key,
        customer: customer,
        salt: salt,
        callbackurl: "#{Rails.application.credentials.dig(Rails.env.to_sym, :host)}/apps/#{application.id}/express/notify"
      })
    end

    def subscribe(number:, kdbm:, mobile:)
      client.subscribe(number, kdbm, { mobiletelephone: mobile }) if client
    end

    def query(number:, kdbm:, mobile:)
      client.query( number, kdbm, { mobiletelephone: mobile }) if client
    end
  end
end
