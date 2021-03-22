# frozen_string_literal: true

module AdminAPI::Entities::Bean::SingleStore
  class SimpleProduct < CustomGrape::Entity
    expose :id
    expose :created_at
    expose :updated_at
    expose :name, documentation: { desc: Bean::Product.human_attribute_name(:name) }
    expose :available_on, documentation: { desc: Bean::Product.human_attribute_name(:available_on), type: DateTime }
    expose :discontinue_on, documentation: { desc: Bean::Product.human_attribute_name(:discontinue_on), type: DateTime }
    expose :shipping_template_id, documentation: { desc: Bean::Product.human_attribute_name(:shipping_template_id), type: Integer }
    expose :share_title, documentation: { desc: Bean::Product.human_attribute_name(:share_title) }
  end

  class Product < SimpleProduct
    expose_attached :main_image
    expose :sales_volume
    expose :taxon_ids, documentation: { desc: Bean::Product.human_attribute_name(:taxon_ids), type: Array[Integer] }
  end

  class ProductDetail < Product
    expose :option_type_ids, documentation: { desc: Bean::Product.human_attribute_name(:option_type_ids), type: Array[Integer] }
    expose :description, documentation: { desc: Bean::Product.human_attribute_name(:description) }
    expose :shipping_template, using: AdminAPI::Entities::Bean::SimpleShippingTemplate
    expose :taxons, using: AdminAPI::Entities::Bean::SimpleTaxon
    expose_attached :image_attachments, as: :images
    expose_attached :detail_image_attachments, as: :detail_images
    expose :variants, using: Variant
    expose_attached :share_image_attachment, as: :share_image, documentation: { desc: Bean::Product.human_attribute_name(:share_image) }
    expose_attached :poster_image_attachment, as: :poster_image, documentation: { desc: Bean::Product.human_attribute_name(:poster_image) }
  end
end
