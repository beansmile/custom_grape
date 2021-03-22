# frozen_string_literal: true

module Bean
  class ExpressService < ApplicationRecord
    # constants

    # concerns

    # attr related macros

    # association macros
    belongs_to :application

    # validation macros

    # callbacks

    # other macros

    # scopes

    # class methods

    # instance methods

    def subscribe
      raise ::NotImplementedError, "You must implement process method for this express service."
    end

    def query
      raise ::NotImplementedError, "You must implement process method for this express service."
    end
  end
end
