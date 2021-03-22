# frozen_string_literal: true

module Bean
  class PaymentMethod < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :application
    has_many :payments, class_name: "Bean::Payment", dependent: :restrict_with_error

    # validation macros

    # callbacks

    # other macros
    mount_uploader :apiclient_cert, ApiclientCertUploader

    # scopes

    # class methods

    # instance methods
    def process
      raise ::NotImplementedError, "You must implement process method for this payment method."
    end
  end
end
