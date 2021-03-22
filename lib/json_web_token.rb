# frozen_string_literal: true

require "jwt"

class JsonWebToken
  KEY = Rails.application.credentials[:secret_key_base]

  # Encodes and signs JWT Payload with expiration
  def self.encode(payload)
    payload.reverse_merge!(meta)

    JWT.encode(payload, KEY)
  end

  # Decodes the JWT with the signed secret
  def self.decode(token)
    JWT.decode(token, KEY)
  end

  # Validates the payload hash for expiration and meta claims
  def self.valid_payload(payload)
    if expired(payload) || payload["issu"] != meta[:issu]
      return false
    else
      return true
    end
  end

  # Default options to be encoded in the token
  def self.meta
    {
      issu: "issu",
      iat: Time.current.to_i,
      expired_at: 7.days.from_now.to_i,
    }
  end

  # Validates if the token is expired by exp parameter
  def self.expired(payload)
    Time.at(payload["expired_at"]) < Time.current
  end
end
