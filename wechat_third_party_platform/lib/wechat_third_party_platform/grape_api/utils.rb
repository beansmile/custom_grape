# frozen_string_literal: true

module WechatThirdPartyPlatform::GrapeAPI
  class Utils < Grape::API
    namespace "wechat_third_party_platform/utils", desc: "工具" do
      before do
        response_error("请先去授权小程序！") unless current_wechat_application_client
      end

      desc "获取小程序码（生产环境且已有在线版本）或体验版二维码", detail: <<-NOTES.strip_heredoc
      ```json
      {
        "path": "https://cdn.staging.magicbeanmall.com/weizhan-staging-files/d0711c20e35_qrcode.jpg"
      }
      ```
      NOTES
      params do
        requires :path, type: String, desc: "小程序页面, 开头不能带'/'符号"
        requires :scene, type: String, desc: "小程序页面参数"
        optional :width, type: Integer, desc: "二维码宽度"
        optional :auto_color, type: Grape::API::Boolean, desc: "自动配置线条颜色"
        optional :line_color, type: JSON, desc: "auto_color 为 false 时生效，使用 rgb 设置颜色"
        optional :is_hyaline, type: Grape::API::Boolean, default: true, desc: "是否需要透明底色"
        optional :binary, type: Grape::API::Boolean, desc: "是获取binary还是返回图片路径"
      end
      get "mini_program_qrcode" do
        response = if Rails.env.production? && current_application.wechat_application.online_submition_id
                     current_wechat_application_client.getwxacodeunlimit(
                       scene: params[:scene],
                       page: params[:path],
                       width: params[:width],
                       auto_color: params[:auto_color],
                       line_color: params[:line_color],
                       is_hyaline: params[:is_hyaline]
                     )
                   else
                     current_wechat_application_client.get_qrcode(path: "#{params[:path]}?#{params[:scene]}")
                   end

        if response.is_a?(String)
          if params[:binary]
            content_type "image/png"
            env["api.format"] = "image/png"
            response
          else
            img_type = params[:is_hyaline] ? "png" : "jpg"
            filename = Digest::MD5.hexdigest(response).concat("_qrcode.#{img_type}")
            folder = "./tmp/wxacode"
            temp_file_path = "#{folder}/#{filename}"
            FileUtils.mkdir_p(folder)

            open(temp_file_path, "wb") do |file|
              file << response
            end
            blob = ActiveStorage::Blob.create_after_upload!(io: File.open(temp_file_path), filename: filename, content_type: "image/#{img_type}")

            { path: blob.service_url }
          end
        else
          response_error(response["errmsg"])
        end
      end

      desc "获取微信用户手机号", detail: <<-NOTES.strip_heredoc
        ```json
      {
        "phoneNumber"=>"1598914xxxx",
        "purePhoneNumber"=>"1598914xxxx",
        "countryCode"=>"86"
      }
      ```
      NOTES
      params do
        requires :encrypted_data, type: String, desc: "完整用户信息的加密数据"
        requires :iv, type: String, desc: "加密算法的初始向量"
      end
      post "authorize_phone" do
        error!("401 Unauthorized", 401) unless current_user

        user_phone_data = current_wechat_application_client.decrypt!(session_key: current_user.send(WechatThirdPartyPlatform.user_session_key_method), encrypted_data: params[:encrypted_data], iv: params[:iv])
        # phoneNumberData:
        # {
        #   "phoneNumber"=>"1598914xxxx",
        #   "purePhoneNumber"=>"1598914xxxx",
        #   "countryCode"=>"86",
        #   "watermark"=>{"timestamp"=>1590565990, "appid"=>"wx93bf3795383fxxxx"}
        # }
        user_phone_data.extract!("watermark")
        present user_phone_data.as_json
      end
    end
  end
end
