# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_12_08_085213) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actions", force: :cascade do |t|
    t.string "action_type", null: false
    t.string "action_option"
    t.string "target_type"
    t.integer "target_id"
    t.string "user_type"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["action_type", "target_type", "target_id", "user_type", "user_id"], name: "uk_action_target_user", unique: true
    t.index ["target_type", "target_id", "action_type"], name: "index_actions_on_target_type_and_target_id_and_action_type"
    t.index ["user_type", "user_id", "action_type"], name: "index_actions_on_user_type_and_user_id_and_action_type"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.integer "position"
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.integer "application_id"
    t.index ["application_id"], name: "index_active_storage_blobs_on_application_id"
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email"
    t.string "phone"
    t.string "password_digest", null: false
    t.string "name"
    t.string "reset_password_token"
    t.string "reset_password_sent_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "admin_users_roles", force: :cascade do |t|
    t.bigint "admin_user_id"
    t.bigint "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "application_id"
    t.bigint "merchant_id"
    t.bigint "store_id"
    t.index ["admin_user_id"], name: "index_admin_users_roles_on_admin_user_id"
    t.index ["application_id"], name: "index_admin_users_roles_on_application_id"
    t.index ["merchant_id"], name: "index_admin_users_roles_on_merchant_id"
    t.index ["role_id"], name: "index_admin_users_roles_on_role_id"
    t.index ["store_id"], name: "index_admin_users_roles_on_store_id"
  end

  create_table "banners", force: :cascade do |t|
    t.string "kind"
    t.jsonb "target", default: {}
    t.integer "position", default: 0
    t.integer "page_position", default: 0
    t.string "alt"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "application_id"
    t.index ["application_id"], name: "index_banners_on_application_id"
  end

  create_table "bean_addresses", force: :cascade do |t|
    t.string "detail_info"
    t.string "postal_code"
    t.string "receiver_name"
    t.string "tel_number"
    t.boolean "is_default", default: false
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "country_id"
    t.bigint "province_id"
    t.bigint "city_id"
    t.bigint "district_id"
    t.index ["city_id"], name: "index_bean_addresses_on_city_id"
    t.index ["country_id"], name: "index_bean_addresses_on_country_id"
    t.index ["district_id"], name: "index_bean_addresses_on_district_id"
    t.index ["province_id"], name: "index_bean_addresses_on_province_id"
    t.index ["user_id"], name: "index_bean_addresses_on_user_id"
  end

  create_table "bean_adjustments", force: :cascade do |t|
    t.string "amount"
    t.string "label"
    t.bigint "order_id", null: false
    t.string "adjustable_type", null: false
    t.bigint "adjustable_id", null: false
    t.string "source_type", null: false
    t.bigint "source_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["adjustable_type", "adjustable_id"], name: "index_bean_adjustments_on_adjustable_type_and_adjustable_id"
    t.index ["order_id"], name: "index_bean_adjustments_on_order_id"
    t.index ["source_type", "source_id"], name: "index_bean_adjustments_on_source_type_and_source_id"
  end

  create_table "bean_after_sale_items", force: :cascade do |t|
    t.integer "quantity"
    t.bigint "after_sale_id", null: false
    t.bigint "line_item_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["after_sale_id"], name: "index_bean_after_sale_items_on_after_sale_id"
    t.index ["line_item_id"], name: "index_bean_after_sale_items_on_line_item_id"
  end

  create_table "bean_after_sales", force: :cascade do |t|
    t.string "number"
    t.integer "state", default: 0
    t.datetime "agreed_at"
    t.string "reason"
    t.decimal "amount"
    t.integer "after_sale_type"
    t.string "reject_reason"
    t.bigint "user_id", null: false
    t.bigint "store_id", null: false
    t.bigint "order_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_bean_after_sales_on_order_id"
    t.index ["store_id"], name: "index_bean_after_sales_on_store_id"
    t.index ["user_id"], name: "index_bean_after_sales_on_user_id"
  end

  create_table "bean_app_configs", force: :cascade do |t|
    t.jsonb "ext_json", default: {}
    t.bigint "application_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["application_id"], name: "index_bean_app_configs_on_application_id"
  end

  create_table "bean_applications", force: :cascade do |t|
    t.string "name"
    t.string "appid"
    t.string "secret"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "mobile"
    t.string "contact"
    t.string "company_name"
    t.datetime "expired_at"
    t.string "access_token"
    t.string "refresh_token"
    t.jsonb "func_info", default: []
    t.bigint "wechat_application_id"
    t.bigint "creator_id"
    t.string "share_title"
    t.string "hotwords", default: [], array: true
    t.index ["creator_id"], name: "index_bean_applications_on_creator_id"
    t.index ["wechat_application_id"], name: "index_bean_applications_on_wechat_application_id"
  end

  create_table "bean_calculators", force: :cascade do |t|
    t.string "type"
    t.jsonb "preferences", default: {}
    t.string "calculable_type", null: false
    t.bigint "calculable_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["calculable_type", "calculable_id"], name: "index_bean_calculators_on_calculable_type_and_calculable_id"
  end

  create_table "bean_cities", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.bigint "province_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_bean_cities_on_code"
    t.index ["province_id"], name: "index_bean_cities_on_province_id"
  end

  create_table "bean_countries", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_bean_countries_on_code"
  end

  create_table "bean_custom_pages", force: :cascade do |t|
    t.string "title"
    t.string "slug"
    t.boolean "default", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "target_type"
    t.bigint "target_id"
    t.bigint "draft_custom_page_id"
    t.datetime "latest_sync_time"
    t.jsonb "configs", default: {}
    t.index ["draft_custom_page_id"], name: "index_bean_custom_pages_on_draft_custom_page_id"
    t.index ["target_type", "target_id"], name: "index_bean_custom_pages_on_target_type_and_target_id"
  end

  create_table "bean_custom_variant_lists", force: :cascade do |t|
    t.string "target_type"
    t.bigint "target_id"
    t.integer "store_variant_ids", default: [], array: true
    t.string "title"
    t.string "remark"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "kind", default: 0
    t.index ["target_type", "target_id"], name: "index_bean_custom_variant_lists_on_target_type_and_target_id"
  end

  create_table "bean_districts", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.bigint "city_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["city_id"], name: "index_bean_districts_on_city_id"
    t.index ["code"], name: "index_bean_districts_on_code"
  end

  create_table "bean_express_services", force: :cascade do |t|
    t.string "name"
    t.jsonb "configs", default: {}
    t.boolean "is_active"
    t.string "type"
    t.bigint "application_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["application_id"], name: "index_bean_express_services_on_application_id"
  end

  create_table "bean_inventory_units", force: :cascade do |t|
    t.integer "quantity"
    t.bigint "store_variant_id", null: false
    t.bigint "order_id", null: false
    t.bigint "shipment_id", null: false
    t.bigint "line_item_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["line_item_id"], name: "index_bean_inventory_units_on_line_item_id"
    t.index ["order_id"], name: "index_bean_inventory_units_on_order_id"
    t.index ["shipment_id"], name: "index_bean_inventory_units_on_shipment_id"
    t.index ["store_variant_id"], name: "index_bean_inventory_units_on_store_variant_id"
  end

  create_table "bean_line_items", force: :cascade do |t|
    t.integer "quantity"
    t.decimal "price", precision: 10, scale: 2
    t.decimal "adjustment_total", precision: 10, scale: 2
    t.bigint "order_id", null: false
    t.bigint "store_variant_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "product_name"
    t.jsonb "option_types", default: []
    t.index ["order_id"], name: "index_bean_line_items_on_order_id"
    t.index ["store_variant_id"], name: "index_bean_line_items_on_store_variant_id"
  end

  create_table "bean_logistics", force: :cascade do |t|
    t.string "number"
    t.string "company"
    t.jsonb "traces", default: {}
    t.string "remark"
    t.bigint "order_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["order_id"], name: "index_bean_logistics_on_order_id"
  end

  create_table "bean_merchants", force: :cascade do |t|
    t.string "name"
    t.boolean "is_active", default: false
    t.bigint "application_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "free_freight_amount", precision: 10, scale: 2
    t.index ["application_id"], name: "index_bean_merchants_on_application_id"
  end

  create_table "bean_option_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "merchant_id"
    t.index ["merchant_id"], name: "index_bean_option_types_on_merchant_id"
  end

  create_table "bean_option_value_variants", force: :cascade do |t|
    t.bigint "variant_id", null: false
    t.bigint "option_value_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["option_value_id"], name: "index_bean_option_value_variants_on_option_value_id"
    t.index ["variant_id"], name: "index_bean_option_value_variants_on_variant_id"
  end

  create_table "bean_option_values", force: :cascade do |t|
    t.string "name"
    t.integer "position"
    t.bigint "option_type_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["option_type_id"], name: "index_bean_option_values_on_option_type_id"
  end

  create_table "bean_orders", force: :cascade do |t|
    t.string "number"
    t.decimal "item_total", precision: 10, scale: 2
    t.decimal "total", precision: 10, scale: 2
    t.decimal "shipment_total", precision: 10, scale: 2
    t.decimal "promo_total", precision: 10, scale: 2, default: "0.0"
    t.decimal "adjustment_total", precision: 10, scale: 2, default: "0.0"
    t.decimal "refund_amount", precision: 10, scale: 2, default: "0.0"
    t.datetime "completed_at"
    t.integer "state", default: 0
    t.integer "shipment_state", default: 0
    t.string "user_remark"
    t.string "admin_user_remark"
    t.bigint "user_id", null: false
    t.bigint "store_id", null: false
    t.bigint "address_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "apply_reason"
    t.integer "order_source_type"
    t.datetime "received_at"
    t.index ["address_id"], name: "index_bean_orders_on_address_id"
    t.index ["store_id"], name: "index_bean_orders_on_store_id"
    t.index ["user_id"], name: "index_bean_orders_on_user_id"
  end

  create_table "bean_payment_methods", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.boolean "is_active", default: false
    t.jsonb "configuration", default: {}
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "application_id"
    t.string "apiclient_cert"
    t.index ["application_id"], name: "index_bean_payment_methods_on_application_id"
  end

  create_table "bean_payments", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2
    t.string "number"
    t.integer "state", default: 0
    t.integer "payment_type"
    t.jsonb "response", default: {}
    t.bigint "order_id", null: false
    t.bigint "payment_method_id", null: false
    t.string "paymentable_type", null: false
    t.bigint "paymentable_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "parent_id"
    t.decimal "refunding_amount", precision: 12, scale: 2, default: "0.0"
    t.decimal "refunded_amount", precision: 12, scale: 2, default: "0.0"
    t.index ["order_id"], name: "index_bean_payments_on_order_id"
    t.index ["parent_id"], name: "index_bean_payments_on_parent_id"
    t.index ["payment_method_id"], name: "index_bean_payments_on_payment_method_id"
    t.index ["paymentable_type", "paymentable_id"], name: "index_bean_payments_on_paymentable_type_and_paymentable_id"
  end

  create_table "bean_product_option_types", force: :cascade do |t|
    t.integer "position"
    t.bigint "option_type_id", null: false
    t.bigint "product_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["option_type_id"], name: "index_bean_product_option_types_on_option_type_id"
    t.index ["product_id"], name: "index_bean_product_option_types_on_product_id"
  end

  create_table "bean_product_taxons", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "taxon_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["product_id"], name: "index_bean_product_taxons_on_product_id"
    t.index ["taxon_id"], name: "index_bean_product_taxons_on_taxon_id"
  end

  create_table "bean_products", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "available_on"
    t.datetime "discontinue_on"
    t.bigint "merchant_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "freight_calculation_type"
    t.decimal "freight_amount", precision: 10, scale: 2
    t.bigint "shipping_template_id"
    t.string "share_title"
    t.index ["merchant_id"], name: "index_bean_products_on_merchant_id"
    t.index ["shipping_template_id"], name: "index_bean_products_on_shipping_template_id"
  end

  create_table "bean_provinces", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.bigint "country_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_bean_provinces_on_code"
    t.index ["country_id"], name: "index_bean_provinces_on_country_id"
  end

  create_table "bean_share_settings", force: :cascade do |t|
    t.string "share_words"
    t.string "target_type"
    t.bigint "target_id"
    t.bigint "store_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["store_id"], name: "index_bean_share_settings_on_store_id"
    t.index ["target_type", "target_id"], name: "index_bean_share_settings_on_target_type_and_target_id"
  end

  create_table "bean_shipments", force: :cascade do |t|
    t.string "number"
    t.string "shipping_method_name"
    t.decimal "cost", precision: 10, scale: 2
    t.jsonb "traces", default: {}
    t.bigint "order_id", null: false
    t.bigint "address_id", null: false
    t.bigint "stock_location_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "state", default: 0
    t.datetime "shipped_at"
    t.bigint "shipping_category_id"
    t.index ["address_id"], name: "index_bean_shipments_on_address_id"
    t.index ["order_id"], name: "index_bean_shipments_on_order_id"
    t.index ["shipping_category_id"], name: "index_bean_shipments_on_shipping_category_id"
    t.index ["stock_location_id"], name: "index_bean_shipments_on_stock_location_id"
  end

  create_table "bean_shipping_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "shipping_template_id"
    t.string "company_code"
    t.index ["shipping_template_id"], name: "index_bean_shipping_categories_on_shipping_template_id"
  end

  create_table "bean_shipping_method_zones", force: :cascade do |t|
    t.bigint "zone_id", null: false
    t.bigint "shipping_method_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["shipping_method_id"], name: "index_bean_shipping_method_zones_on_shipping_method_id"
    t.index ["zone_id"], name: "index_bean_shipping_method_zones_on_zone_id"
  end

  create_table "bean_shipping_methods", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "shipping_category_id"
    t.boolean "is_default", default: false
    t.index ["shipping_category_id"], name: "index_bean_shipping_methods_on_shipping_category_id"
  end

  create_table "bean_shipping_rates", force: :cascade do |t|
    t.boolean "selected", default: false
    t.decimal "cost", precision: 10, scale: 2
    t.bigint "shipment_id", null: false
    t.bigint "shipping_method_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["shipment_id"], name: "index_bean_shipping_rates_on_shipment_id"
    t.index ["shipping_method_id"], name: "index_bean_shipping_rates_on_shipping_method_id"
  end

  create_table "bean_shipping_templates", force: :cascade do |t|
    t.string "name"
    t.integer "calculate_type"
    t.bigint "merchant_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["merchant_id"], name: "index_bean_shipping_templates_on_merchant_id"
  end

  create_table "bean_shopping_cart_items", force: :cascade do |t|
    t.bigint "store_variant_id", null: false
    t.bigint "shopping_cart_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "quantity"
    t.index ["shopping_cart_id"], name: "index_bean_shopping_cart_items_on_shopping_cart_id"
    t.index ["store_variant_id"], name: "index_bean_shopping_cart_items_on_store_variant_id"
  end

  create_table "bean_shopping_carts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_bean_shopping_carts_on_user_id"
  end

  create_table "bean_stock_location_items", force: :cascade do |t|
    t.integer "count_on_hand", default: 0
    t.bigint "stock_location_id", null: false
    t.bigint "variant_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["stock_location_id"], name: "index_bean_stock_location_items_on_stock_location_id"
    t.index ["variant_id"], name: "index_bean_stock_location_items_on_variant_id"
  end

  create_table "bean_stock_locations", force: :cascade do |t|
    t.string "name"
    t.boolean "is_active", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bean_store_stock_locations", force: :cascade do |t|
    t.bigint "store_id", null: false
    t.bigint "stock_location_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["stock_location_id"], name: "index_bean_store_stock_locations_on_stock_location_id"
    t.index ["store_id"], name: "index_bean_store_stock_locations_on_store_id"
  end

  create_table "bean_store_variants", force: :cascade do |t|
    t.integer "sales_volume", default: 0
    t.decimal "cost_price", precision: 10, scale: 2
    t.decimal "origin_price", precision: 10, scale: 2
    t.boolean "is_active", default: false
    t.bigint "variant_id", null: false
    t.bigint "store_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "is_master", default: false
    t.index ["store_id"], name: "index_bean_store_variants_on_store_id"
    t.index ["variant_id"], name: "index_bean_store_variants_on_variant_id"
  end

  create_table "bean_stores", force: :cascade do |t|
    t.string "name"
    t.bigint "merchant_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "discontinue_on"
    t.index ["merchant_id"], name: "index_bean_stores_on_merchant_id"
  end

  create_table "bean_taxonomies", force: :cascade do |t|
    t.string "name"
    t.integer "taxonomy_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "merchant_id"
    t.integer "position", default: 0
    t.index ["merchant_id"], name: "index_bean_taxonomies_on_merchant_id"
  end

  create_table "bean_taxons", force: :cascade do |t|
    t.string "name"
    t.bigint "taxonomy_id", null: false
    t.bigint "parent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "position", default: 0
    t.index ["parent_id"], name: "index_bean_taxons_on_parent_id"
    t.index ["taxonomy_id"], name: "index_bean_taxons_on_taxonomy_id"
  end

  create_table "bean_variants", force: :cascade do |t|
    t.string "sku"
    t.integer "position"
    t.boolean "track_inventory", default: false
    t.bigint "product_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "weight", precision: 8, scale: 2
    t.decimal "length", precision: 8, scale: 2
    t.decimal "width", precision: 8, scale: 2
    t.decimal "depth", precision: 8, scale: 2
    t.boolean "is_active", default: false
    t.index ["product_id"], name: "index_bean_variants_on_product_id"
  end

  create_table "bean_zone_members", force: :cascade do |t|
    t.bigint "zone_id", null: false
    t.string "zoneable_type", null: false
    t.bigint "zoneable_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["zone_id"], name: "index_bean_zone_members_on_zone_id"
    t.index ["zoneable_type", "zoneable_id"], name: "index_bean_zone_members_on_zoneable_type_and_zoneable_id"
  end

  create_table "bean_zones", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "kind"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bs_wechat_mini_program_wechat_subscribes", force: :cascade do |t|
    t.string "openid"
    t.string "event"
    t.string "target_type", null: false
    t.bigint "target_id", null: false
    t.integer "status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["target_type", "target_id"], name: "index_bs_wechat_mini_program_wechat_subscribe_on_target"
  end

  create_table "oauth_identities", force: :cascade do |t|
    t.string "provider", default: "", null: false
    t.string "primary_uid", default: "", null: false
    t.string "secondary_uid"
    t.json "credentials", default: {}, null: false
    t.json "user_info", default: {}, null: false
    t.json "extra", default: {}, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["primary_uid"], name: "index_oauth_identities_on_primary_uid"
    t.index ["secondary_uid"], name: "index_oauth_identities_on_secondary_uid"
    t.index ["user_id"], name: "index_oauth_identities_on_user_id"
  end

  create_table "pages", force: :cascade do |t|
    t.text "content"
    t.string "title", null: false
    t.string "type", null: false
    t.string "slug", null: false
    t.integer "status", default: 0
    t.integer "views_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "application_id"
    t.index ["application_id"], name: "index_pages_on_application_id"
    t.index ["slug", "application_id"], name: "index_pages_on_slug_and_application_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.string "email"
    t.string "phone"
    t.integer "gender", default: 0, null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.text "permissions"
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "store_id"
    t.integer "kind", default: 0
    t.jsonb "custom_permissions", default: {}
    t.index ["store_id"], name: "index_roles_on_store_id"
  end

  create_table "settings", force: :cascade do |t|
    t.string "name"
    t.string "var", null: false
    t.text "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["var"], name: "index_settings_on_var", unique: true
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.integer "application_id"
    t.index ["application_id"], name: "index_taggings_on_application_id"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "screen_name", default: "", null: false
    t.string "tracking_code", null: false
    t.datetime "sns_authorized_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "application_id"
    t.index ["application_id"], name: "index_users_on_application_id"
    t.index ["tracking_code"], name: "index_users_on_tracking_code", unique: true
  end

  create_table "wechat_third_party_platform_applications", force: :cascade do |t|
    t.string "appid"
    t.integer "account_type"
    t.integer "principal_type"
    t.string "principal_name"
    t.string "access_token"
    t.string "refresh_token"
    t.jsonb "func_info", default: [], array: true
    t.bigint "register_id"
    t.integer "source", default: 0
    t.string "nick_name", comment: "昵称"
    t.string "user_name", comment: "原始 ID"
    t.jsonb "mini_program_info", default: {}
    t.string "new_name"
    t.integer "name_changed_status", default: 0
    t.string "name_rejected_reason"
    t.integer "authorization_status", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "audit_submition_id"
    t.bigint "online_submition_id"
    t.bigint "trial_submition_id"
    t.integer "binded_project_application_id"
    t.index ["appid"], name: "index_wechat_third_party_platform_applications_on_appid", unique: true
    t.index ["audit_submition_id"], name: "index_wtpp_applications_on_audit_submition_id"
    t.index ["online_submition_id"], name: "index_wtpp_applications_on_online_submition_id"
    t.index ["register_id"], name: "index_wtpp_applications_on_register_id"
    t.index ["trial_submition_id"], name: "index_wtpp_applications_on_trial_submition_id"
  end

  create_table "wechat_third_party_platform_registers", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.string "code_type"
    t.string "legal_persona_wechat"
    t.string "legal_persona_name"
    t.string "component_phone"
    t.jsonb "audit_result", default: {}
    t.integer "state", default: 0
    t.bigint "creator_id"
    t.bigint "application_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["application_id"], name: "index_wechat_third_party_platform_registers_on_application_id"
    t.index ["creator_id"], name: "index_wechat_third_party_platform_registers_on_creator_id"
  end

  create_table "wechat_third_party_platform_submitions", force: :cascade do |t|
    t.string "template_id"
    t.jsonb "ext_json", default: {}
    t.jsonb "audit_result", default: {}
    t.string "user_version"
    t.string "user_desc"
    t.integer "state", default: 0
    t.integer "application_id"
    t.string "auditid"
    t.boolean "auto_release", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["application_id"], name: "index_wechat_third_party_platform_submitions_on_application_id"
    t.index ["template_id"], name: "index_wechat_third_party_platform_submitions_on_template_id"
  end

  create_table "wechat_third_party_platform_template_settings", force: :cascade do |t|
    t.integer "latest_template_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "wechat_third_party_platform_testers", force: :cascade do |t|
    t.string "wechat_id"
    t.string "userstr"
    t.integer "application_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["application_id"], name: "index_wechat_third_party_platform_testers_on_application_id"
  end

  create_table "wechat_third_party_platform_visit_data", force: :cascade do |t|
    t.string "appid"
    t.string "ref_date"
    t.string "session_cnt"
    t.integer "visit_pv", default: 0
    t.integer "visit_uv", default: 0
    t.integer "visit_uv_new", default: 0
    t.string "stay_time_uv"
    t.string "stay_time_session"
    t.string "visit_depth"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["appid"], name: "index_wechat_third_party_platform_visit_data_on_appid"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "admin_users_roles", "bean_applications", column: "application_id"
  add_foreign_key "admin_users_roles", "bean_merchants", column: "merchant_id"
  add_foreign_key "admin_users_roles", "bean_stores", column: "store_id"
  add_foreign_key "banners", "bean_applications", column: "application_id"
  add_foreign_key "bean_addresses", "bean_cities", column: "city_id"
  add_foreign_key "bean_addresses", "bean_countries", column: "country_id"
  add_foreign_key "bean_addresses", "bean_districts", column: "district_id"
  add_foreign_key "bean_addresses", "bean_provinces", column: "province_id"
  add_foreign_key "bean_addresses", "users"
  add_foreign_key "bean_adjustments", "bean_orders", column: "order_id"
  add_foreign_key "bean_after_sale_items", "bean_after_sales", column: "after_sale_id"
  add_foreign_key "bean_after_sale_items", "bean_line_items", column: "line_item_id"
  add_foreign_key "bean_after_sales", "bean_orders", column: "order_id"
  add_foreign_key "bean_after_sales", "bean_stores", column: "store_id"
  add_foreign_key "bean_after_sales", "users"
  add_foreign_key "bean_app_configs", "bean_applications", column: "application_id"
  add_foreign_key "bean_applications", "admin_users", column: "creator_id"
  add_foreign_key "bean_applications", "wechat_third_party_platform_applications", column: "wechat_application_id"
  add_foreign_key "bean_cities", "bean_provinces", column: "province_id"
  add_foreign_key "bean_custom_pages", "bean_custom_pages", column: "draft_custom_page_id"
  add_foreign_key "bean_districts", "bean_cities", column: "city_id"
  add_foreign_key "bean_express_services", "bean_applications", column: "application_id"
  add_foreign_key "bean_inventory_units", "bean_line_items", column: "line_item_id"
  add_foreign_key "bean_inventory_units", "bean_orders", column: "order_id"
  add_foreign_key "bean_inventory_units", "bean_shipments", column: "shipment_id"
  add_foreign_key "bean_inventory_units", "bean_store_variants", column: "store_variant_id"
  add_foreign_key "bean_line_items", "bean_orders", column: "order_id"
  add_foreign_key "bean_line_items", "bean_store_variants", column: "store_variant_id"
  add_foreign_key "bean_logistics", "bean_orders", column: "order_id"
  add_foreign_key "bean_merchants", "bean_applications", column: "application_id"
  add_foreign_key "bean_option_types", "bean_merchants", column: "merchant_id"
  add_foreign_key "bean_option_value_variants", "bean_option_values", column: "option_value_id"
  add_foreign_key "bean_option_value_variants", "bean_variants", column: "variant_id"
  add_foreign_key "bean_option_values", "bean_option_types", column: "option_type_id"
  add_foreign_key "bean_orders", "bean_addresses", column: "address_id"
  add_foreign_key "bean_orders", "bean_stores", column: "store_id"
  add_foreign_key "bean_orders", "users"
  add_foreign_key "bean_payment_methods", "bean_applications", column: "application_id"
  add_foreign_key "bean_payments", "bean_orders", column: "order_id"
  add_foreign_key "bean_payments", "bean_payment_methods", column: "payment_method_id"
  add_foreign_key "bean_payments", "bean_payments", column: "parent_id"
  add_foreign_key "bean_product_option_types", "bean_option_types", column: "option_type_id"
  add_foreign_key "bean_product_option_types", "bean_products", column: "product_id"
  add_foreign_key "bean_product_taxons", "bean_products", column: "product_id"
  add_foreign_key "bean_product_taxons", "bean_taxons", column: "taxon_id"
  add_foreign_key "bean_products", "bean_merchants", column: "merchant_id"
  add_foreign_key "bean_products", "bean_shipping_templates", column: "shipping_template_id"
  add_foreign_key "bean_provinces", "bean_countries", column: "country_id"
  add_foreign_key "bean_shipments", "bean_addresses", column: "address_id"
  add_foreign_key "bean_shipments", "bean_orders", column: "order_id"
  add_foreign_key "bean_shipments", "bean_shipments", column: "shipping_category_id"
  add_foreign_key "bean_shipments", "bean_stock_locations", column: "stock_location_id"
  add_foreign_key "bean_shipping_categories", "bean_shipping_templates", column: "shipping_template_id"
  add_foreign_key "bean_shipping_method_zones", "bean_shipping_methods", column: "shipping_method_id"
  add_foreign_key "bean_shipping_method_zones", "bean_zones", column: "zone_id"
  add_foreign_key "bean_shipping_methods", "bean_shipping_categories", column: "shipping_category_id"
  add_foreign_key "bean_shipping_rates", "bean_shipments", column: "shipment_id"
  add_foreign_key "bean_shipping_rates", "bean_shipping_methods", column: "shipping_method_id"
  add_foreign_key "bean_shipping_templates", "bean_merchants", column: "merchant_id"
  add_foreign_key "bean_shopping_cart_items", "bean_shopping_carts", column: "shopping_cart_id"
  add_foreign_key "bean_shopping_cart_items", "bean_store_variants", column: "store_variant_id"
  add_foreign_key "bean_shopping_carts", "users"
  add_foreign_key "bean_stock_location_items", "bean_stock_locations", column: "stock_location_id"
  add_foreign_key "bean_stock_location_items", "bean_variants", column: "variant_id"
  add_foreign_key "bean_store_stock_locations", "bean_stock_locations", column: "stock_location_id"
  add_foreign_key "bean_store_stock_locations", "bean_stores", column: "store_id"
  add_foreign_key "bean_store_variants", "bean_stores", column: "store_id"
  add_foreign_key "bean_store_variants", "bean_variants", column: "variant_id"
  add_foreign_key "bean_stores", "bean_merchants", column: "merchant_id"
  add_foreign_key "bean_taxonomies", "bean_merchants", column: "merchant_id"
  add_foreign_key "bean_taxons", "bean_taxonomies", column: "taxonomy_id"
  add_foreign_key "bean_taxons", "bean_taxons", column: "parent_id"
  add_foreign_key "bean_variants", "bean_products", column: "product_id"
  add_foreign_key "bean_zone_members", "bean_zones", column: "zone_id"
  add_foreign_key "oauth_identities", "users"
  add_foreign_key "pages", "bean_applications", column: "application_id"
  add_foreign_key "profiles", "users"
  add_foreign_key "roles", "bean_stores", column: "store_id"
  add_foreign_key "taggings", "tags"
  add_foreign_key "users", "bean_applications", column: "application_id"
  add_foreign_key "wechat_third_party_platform_applications", "wechat_third_party_platform_registers", column: "register_id"
  add_foreign_key "wechat_third_party_platform_applications", "wechat_third_party_platform_submitions", column: "audit_submition_id"
  add_foreign_key "wechat_third_party_platform_applications", "wechat_third_party_platform_submitions", column: "online_submition_id"
  add_foreign_key "wechat_third_party_platform_applications", "wechat_third_party_platform_submitions", column: "trial_submition_id"
end
