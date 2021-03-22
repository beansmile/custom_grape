 # frozen_string_literal: true

module WechatThirdPartyPlatform
  module AuthorizationHandlerConcern
    extend ActiveSupport::Concern

    # https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/api/authorize_event.html
    # 授权变更通知推送-授权成功
    # <xml>
    #   <AppId>第三方平台appid</AppId>
    #   <CreateTime>1413192760</CreateTime>
    #   <InfoType>authorized</InfoType>
    #   <AuthorizerAppid>公众号appid</AuthorizerAppid>
    #   <AuthorizationCode>授权码</AuthorizationCode>
    #   <AuthorizationCodeExpiredTime>过期时间</AuthorizationCodeExpiredTime>
    #   <PreAuthCode>预授权码</PreAuthCode>
    # <xml>
    def authorized_handler(msg_hash)
      if authorizer_authorized!
        WechatThirdPartyPlatform.cache_pre_auth_code(msg_hash["PreAuthCode"])
      end
    end

    # https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/api/authorize_event.html
    # 授权变更通知推送-取消授权
    # <xml>
    #   <AppId>第三方平台appid</AppId>
    #   <CreateTime>1413192760</CreateTime>
    #   <InfoType>unauthorized</InfoType>
    #   <AuthorizerAppid>公众号appid</AuthorizerAppid>
    # </xml>
    def unauthorized_handler(msg_hash)
      authorization_unauthorize!
    end

    # https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/api/authorize_event.html
    # 授权变更通知推送-取消授权
    # <xml>
    #   <AppId>第三方平台appid</AppId>
    #   <CreateTime>1413192760</CreateTime>
    #   <InfoType>updateauthorized</InfoType>
    #   <AuthorizerAppid>公众号appid</AuthorizerAppid>
    #   <AuthorizationCode>授权码</AuthorizationCode>
    #   <AuthorizationCodeExpiredTime>过期时间</AuthorizationCodeExpiredTime>
    #   <PreAuthCode>预授权码</PreAuthCode>
    # <xml>
    def updateauthorized_handler(msg_hash)
      if authorizer_updateauthorized!
        WechatThirdPartyPlatform.cache_pre_auth_code(msg_hash["PreAuthCode"])
      end
    end

    # 代码审核结果推送 - 审核通过
    # https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/Mini_Programs/code/audit_event.html
    # <xml>
    #   <ToUserName><![CDATA[gh_fb9688c2a4b2]]></ToUserName>
    #   <FromUserName><![CDATA[od1P50M-fNQI5Gcq-trm4a7apsU8]]></FromUserName>
    #   <CreateTime>1488856741</CreateTime>
    #   <MsgType><![CDATA[event]]></MsgType>
    #   <Event><![CDATA[weapp_audit_success]]></Event>
    #   <SuccTime>1488856741</SuccTime>
    # </xml>
    def weapp_audit_success_handler(msg_hash)
      handle_weapp_audit_success(msg_hash: msg_hash)
    end

    # 代码审核结果推送 - 审核不通过
    # https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/Mini_Programs/code/audit_event.html
    # <xml>
    #   <ToUserName><![CDATA[gh_fb9688c2a4b2]]></ToUserName>
    #   <FromUserName><![CDATA[od1P50M-fNQI5Gcq-trm4a7apsU8]]></FromUserName>
    #   <CreateTime>1488856591</CreateTime>
    #   <MsgType><![CDATA[event]]></MsgType>
    #   <Event><![CDATA[weapp_audit_fail]]></Event>
    #   <Reason><![CDATA[1:账号信息不符合规范:<br>(1):包含色情因素<br>2:服务类目"金融业-保险_"与你提交代码审核时设置的功能页面内容不一致:<br>(1):功能页面设置的部分标签不属于所选的服务类目范围。<br>(2):功能页面设置的部分标签与该页面内容不相关。<br>]]></Reason>
    #   <FailTime>1488856591</FailTime>
    #   <ScreenShot>xxx|yyy|zzz</ScreenShot>
    # </xml>
    def weapp_audit_fail_handler(msg_hash)
      return unless audit_submition
      return unless audit_submition.pending? || audit_submition.delay?

      audit_submition.update(audit_result: msg_hash, state: :fail)
    end

    # 代码审核结果推送 - 审核延后
    # https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/Mini_Programs/code/audit_event.html
    #
    # <xml>
    #   <ToUserName><![CDATA[gh_fb9688c2a4b2]]></ToUserName>
    #   <FromUserName><![CDATA[od1P50M-fNQI5Gcq-trm4a7apsU8]]></FromUserName>
    #   <CreateTime>1488856591</CreateTime>
    #   <MsgType><![CDATA[event]]></MsgType>
    #   <Event><![CDATA[weapp_audit_delay]]></Event>
    #   <Reason><![CDATA[为了更好的服务小程序，您的服务商正在进行提审系统的优化，可能会导致审核时效的增长，请耐心等待]]></Reason>
    #   <DelayTime>1488856591</DelayTime>
    # </xml>
    def weapp_audit_delay_handler(msg_hash)
      return unless audit_submition
      return unless audit_submition.pending? || audit_submition.delay?

      audit_submition.update(audit_result: msg_hash, state: :delay)
    end

    # https://developers.weixin.qq.com/doc/oplatform/Third-party_Platforms/Mini_Programs/wxa_nickname_audit.html
    # <xml>
    #   <ToUserName><![CDATA[gh_fxxxxxxxa4b2]]></ToUserName>
    #   <FromUserName><![CDATA[odxxxxM-xxxxxxxx-trm4a7apsU8]]></FromUserName>
    #   <CreateTime>1488800000</CreateTime>
    #   <MsgType><![CDATA[event]]></MsgType>
    #   <Event><![CDATA[wxa_nickname_audit]]></Event>
    #   <ret>2</ret>
    #   <nickname>昵称</nickname>
    #   <reason>驳回原因</reason>
    # </xml>
    def wxa_nickname_audit_handler(msg_hash)
      return if blank? || !name_submitting?

      # 审核结果 2：失败，3：成功
      msg_hash["ret"] == 3 ? name_to_effective! : reject_name_changed!(msg_hash["reason"])
    end
  end
end
