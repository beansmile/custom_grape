# frozen_string_literal: true

FactoryBot.define do
  factory :taxonomy, class: "Bean::Taxonomy" do
    name { "name" }
    taxonomy_type { "category" }
    merchant
  end
end
