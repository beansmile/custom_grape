# frozen_string_literal: true

class AdminAPI::V1::Bean::BatchStoreVariantForms < API
  namespace "bean/products/:product_id/batch_store_variant_forms" do
    desc "批量店铺商品表单详情", {
      summary: "批量店铺商品表单详情",
      success: AdminAPI::Entities::Bean::BatchStoreVariantForm
    }
    get do
      # 目前只有店铺管理员可以编辑store_variant
      batch_store_variant_form = Bean::BatchStoreVariantForm.new(product_id: params[:product_id], store_id: current_store.id)

      authorize! :read, batch_store_variant_form

      present batch_store_variant_form, with: AdminAPI::Entities::Bean::BatchStoreVariantForm
    end

    desc "批量编辑店铺商品表单", {
      summary: "批量编辑店铺商品表单",
      success: AdminAPI::Entities::Bean::BatchStoreVariantForm
    }
    params do
      requires :store_variant_forms_attributes, type: Array[JSON] do
        optional :count_on_hand, type: Integer
        optional :store_variant_id, type: Integer
        optional :store_variant_attributes, type: JSON do
          optional :all, using: AdminAPI::Entities::Bean::StoreVariant.documentation.slice(
            :cost_price,
            :origin_price,
            :is_active
          )
        end
      end
    end
    put do
      batch_store_variant_form = Bean::BatchStoreVariantForm.new({ product_id: params[:product_id], store_id: current_store.id })
      batch_store_variant_form.assign_attributes(resource_params)

      authorize! :update, batch_store_variant_form

      if batch_store_variant_form.save
        present batch_store_variant_form, with: AdminAPI::Entities::Bean::BatchStoreVariantForm
      else
        response_record_error(batch_store_variant_form)
      end
    end
  end
end
