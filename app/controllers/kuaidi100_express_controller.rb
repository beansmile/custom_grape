# frozen_string_literal: true

class Kuaidi100ExpressController < ApplicationController
  skip_before_action :verify_authenticity_token

  def notify
    app = Bean::Application.find(params[:id])
    app_salt = app.kuaidi100_service.salt
    if Kuaidi100::Sign.callback_verify?(params, app_salt)
      response = JSON.parse params["param"]

      result = response["lastResult"]
      if result
        shipment = Bean::Shipment.find_by(number: result["nu"])
        if shipment
          if result["status"].to_i == 200 && result["data"].present?
            shipment.update(traces: result["data"])
          end
          render json: { result: true, returnCode: "200", message: "成功" }
        end
      end
    else
      render json: { result: false, returnCode: "500", message: "失败" }, status: 500
    end
  end
end
