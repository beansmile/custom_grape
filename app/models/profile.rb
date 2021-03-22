# frozen_string_literal: true

class Profile < ApplicationRecord
  # constants

  # concerns

  # attr related macros
  enum gender: { unknown: 0, male: 1, female: 2 }


  # association macros
  belongs_to :user

  # validation macros

  # callbacks

  # other macros

  # scopes

  # class methods

  # instance methods
end
