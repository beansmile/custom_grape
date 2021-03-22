# frozen_string_literal: true

module Wechat
  class API
    include HTTParty
    HTTP_ERRORS = [
      EOFError,
      Errno::ECONNRESET,
      Errno::EINVAL,
      Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError,
      Net::ProtocolError,
      Timeout::Error
    ]
    HTTPARTY_TIMEOUT = 5
    RETRY_TIMES = 3
    QRCODE_PATH = File.join Rails.root, "public", "uploads", "qrcodes"
    RELATIVE_PATH = File.join "uploads", "qrcodes"

    base_uri "https://api.weixin.qq.com"

    @@logger = ::Logger.new("./log/wx_app_api.log")

    def self.msg_sec_check(content)
      body = {
        content: content
      }
      wx_app_post("/wxa/msg_sec_check", body: body)
    end

    def self.wx_app_post(path, options = {}, need_access_token = true)
      tries = RETRY_TIMES
      body = (options[:body] || {})
      headers = (options[:headers] || {}).reverse_merge({
        "Content-Type" => "application/json"
      })
      path = "#{path}?access_token=#{Wechat::AccessToken.get_mini_program_access_token}" if need_access_token

      @@logger.debug("request: method: post, url: #{path}, body: #{body}, headers: #{headers}")
      response = begin
                   post(path, body: JSON.pretty_generate(body), headers: headers, timeout: HTTPARTY_TIMEOUT)
                 rescue *HTTP_ERRORS => error
                   (tries -= 1) > 0 ? retry : { "msg" => "连接超时" }
                 rescue StandardError => error
                    # 偶尔出现 undefined method body for nil
                   (tries -= 1) > 0 ? retry : {"msg" => "其他错误"}
                 end
      @@logger.debug("response: #{response}")
      response
    end

    def self.wx_qrcode_url
      "/wxa/getwxacodeunlimit"
    end

    # [{
    #    "ref_date"=>"20180713",
    #    "session_cnt"=>39,
    #    "visit_pv"=>142,
    #    "visit_uv"=>12,
    #    "visit_uv_new"=>1,
    #    "stay_time_uv"=>202.8333,
    #    "stay_time_session"=>62.4103,
    #    "visit_depth"=>2.0256
    # }]
    def self.get_weanalysis_appid_daily_visit_trend(begin_date, end_date)
      (begin_date..end_date).map do |date|
        if %w[staging production].include?(Rails.env)
          data_in_redis = Analyses::Cache.get("getweanalysisappiddailyvisittrend", date)
          if data_in_redis
            ActiveSupport::JSON.decode(data_in_redis)
          elsif date < Date.current
            result = wx_app_post("/datacube/getweanalysisappiddailyvisittrend", body: { begin_date: date, end_date: date })
            next if result["errcode"]

            object = result["list"][0]

            Analyses::Cache.set("getweanalysisappiddailyvisittrend", date, object.to_json)
            object
          end
        end
      end
    end

    # https://developers.weixin.qq.com/miniprogram/dev/api-backend/open-api/subscribe-message/subscribeMessage.send.html
    def self.send_subscribe_template(openid, template_id, data, page = nil)
      body = {
        touser: openid,
        template_id: template_id,
        data: data,
        page: page,
        miniprogram_state: Rails.env.production? ? "formal" : "trial"
      }
      wx_app_post("/cgi-bin/message/subscribe/send", body: body)
    end

    def self.logger
      @@logger
    end
  end
end
