# frozen_string_literal: true

FactoryBot.define do
  factory :product, class: "Bean::Product" do
    name { "name" }
    merchant
    shipping_template

    after(:build) do |object|
      taxon = create(:taxon, taxonomy: create(:taxonomy, merchant: object.merchant))

      object.taxon_ids = [taxon.id]

      [:images].each do |attribute|
        object.send(attribute).attach(io: File.open(Rails.root.join("spec/support/files/file.png")), filename: "file.png", content_type: "image/png")
      end
    end
  end
end
