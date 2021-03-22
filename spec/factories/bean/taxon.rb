# frozen_string_literal: true

FactoryBot.define do
  factory :taxon, class: "Bean::Taxon" do
    name { "name" }
    taxonomy
  end
end
