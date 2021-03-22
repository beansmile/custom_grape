# frozen_string_literal: true

module AdminAPI::Entities::Bean
  class SimpleCountry < ::Entities::Model
    expose :name
    expose :code
  end

  class Country < SimpleCountry
  end

  class CountryDetail < Country
  end
end
