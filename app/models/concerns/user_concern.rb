# frozen_string_literal: true

module UserConcern
  extend ActiveSupport::Concern

  def get_access_token
    access_token = JsonWebToken.encode({
      "#{self.class.name.underscore}_id": id
    })
    { token: access_token }
  end
end
