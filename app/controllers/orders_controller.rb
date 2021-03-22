# frozen_string_literal: true

class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def notify
    result = Hash.from_xml(request.body.read)["xml"]
    payment = Bean::Payment.charge_payment_type.find_by(number: result["out_trade_no"])

    if WxPay::Sign.verify?(result, key: payment.payment_method.mch_key)
      payment.handle_pay_notify(result)

      # find your order and process the post-paid logic.
      render xml: {return_code: "SUCCESS"}.to_xml(root: "xml", dasherize: false)
    else
      render xml: {return_code: "FAIL", return_msg: "签名失败"}.to_xml(root: "xml", dasherize: false)
    end
  end

  def refund_notify
    encrypt_result = Hash.from_xml(request.body.read)["xml"]
    payment_method = Bean::PaymentMethod.where('configuration @> ?', { mch_id: encrypt_result["mch_id"] , appid: encrypt_result["appid"] }.to_json).first
    decrypt_result = Hash.from_xml(decrypt_data(encrypt_result["req_info"], payment_method.configuration["mch_key"]))["root"]
    out_refund_no = decrypt_result["out_refund_no"]

    payment = Bean::Payment.refund_payment_type.find_by(number: out_refund_no)
    payment.handle_refund_notify(decrypt_result)

    render xml: {return_code: "SUCCESS"}.to_xml(root: "xml", dasherize: false)
  end

  private

  # https://pay.weixin.qq.com/wiki/doc/api/jsapi.php?chapter=9_16
  def decrypt_data(encrypted_base64, mch_key)
    encrypted = Base64.decode64(encrypted_base64)
    decipher = OpenSSL::Cipher::AES256.new(:ECB)
    decipher.decrypt
    decipher.key = Digest::MD5.hexdigest(mch_key)
    data = decipher.update(encrypted) + decipher.final
    data
  end
end
