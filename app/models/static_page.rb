# frozen_string_literal: true

class StaticPage < Page
  # constants
  SLUG_LENGTH = 8
  # concerns

  # attr related macros
  default_value_for :slug do
    loop do
      new_slug = GlobalConstant::ALPHABET_ARRAY.sample(SLUG_LENGTH).join
      break new_slug unless Page.exists?(slug: new_slug)
    end
  end

  default_value_for :status, :draft
  # association macros

  # validation macros

  # callbacks

  # other macros

  # scopes

  # class methods

  # instance methods
end
