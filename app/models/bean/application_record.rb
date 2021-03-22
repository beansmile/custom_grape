# frozen_string_literal: true

class Bean::ApplicationRecord < ApplicationRecord
  self.abstract_class = true
  self.table_name_prefix = "bean_"
end
