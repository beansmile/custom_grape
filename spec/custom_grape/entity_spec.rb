require "pry"

RSpec.describe CustomGrape::Entity do
  let(:variant_data_children_entities_variant_category) do
    {
      name: "variant_category",
      entity: VariantCategoryEntity,
      includes: true,
      only: nil,
      except: nil
    }
  end
  let(:product_data_children_entities_variant) do
    {
      name: "variants",
      entity: VariantEntity,
      includes: true,
      only: product_data_children_entities_variant_only,
      except: product_data_children_entities_variant_except
    }
  end
  let(:product_data_children_entities_variant_only) { nil }
  let(:product_data_children_entities_variant_except) { nil }

  before :all do
    variant_category_entity = Object.const_set("VariantCategoryEntity", Class.new(CustomGrape::Entity))
    variant_category_entity.expose :id
    variant_category_entity.expose :name
    variant_category_entity.expose :code

    variant_brand_entity = Object.const_set("VariantBrandEntity", Class.new(CustomGrape::Entity))
    variant_brand_entity.expose :id
    variant_brand_entity.expose :name

    variant_entity = Object.const_set("VariantEntity", Class.new(CustomGrape::Entity))
    variant_entity.expose :id
    variant_entity.expose :sku
    variant_entity.expose :variant_category do |object, opts|
      VariantCategoryEntity.represent(object.variant_category, handle_opts(opts))
    end
    variant_entity.expose :variant_brand do |object, opts|
      VariantBrandEntity.represent(object.variant_brand, handle_opts(opts))
    end

    product_category_entity = Object.const_set("ProductCategoryEntity", Class.new(CustomGrape::Entity))
    product_category_entity.expose :name

    product_entity = Object.const_set("ProductEntity", Class.new(CustomGrape::Entity))
    product_entity.expose :name
    product_entity.expose :product_category do |object, opts|
      ProductCategoryEntity.represent(object.product_category, handle_opts(opts))
    end
    product_entity.expose :variants do |object, opts|
      VariantEntity.represent(object.variants, handle_opts(opts))
    end

    CustomGrape::Data.collection = {}
    CustomGrape::Data.build("VariantCategoryEntity")
    CustomGrape::Data.build("VariantBrandEntity")
    CustomGrape::Data.build("VariantEntity")
    CustomGrape::Data.build("ProductCategoryEntity")
    CustomGrape::Data.build("ProductEntity")
  end

  describe ".merge_only" do
    it "get correct result" do
      first_array = [:id, :name, :product_category, variants: [:id, :sku, variant_category: [:id]]]
      second_array = [:id, product_category: [:id], variants: [:sku, :variant_category]]

      expect(CustomGrape::Entity.merge_only(first_array, second_array)).to eq([
        :id, { product_category: [:id] }, { variants: [:sku, { variant_category: [:id] }] }
      ])
    end
  end

  describe ".merge_except" do
    it "get correct result" do
      first_array = [:id, :product_category, variants: [:id, :sku, variant_category: [:id]]]
      second_array = [:name, product_category: [:id], variants: [:sku, :variant_category]]

      expect(CustomGrape::Entity.merge_except(first_array, second_array)).to eq([
        :id, :product_category, { variants: [:id, :sku, :variant_category] }, :name
      ])
    end

    it "get correct result" do
      first_array = [:id, :product_category, variants: [:id, :sku, variant_category: [:id]]]
      second_array = [:name, product_category: [:id], variants: [:sku]]

      expect(CustomGrape::Entity.merge_except(first_array, second_array)).to eq([
        :id, :product_category, { variants: [:id, :sku, variant_category: [:id]] }, :name
      ])
    end
  end

  describe "#represent" do
    let(:represent_options) { {} }

    before do
      variant_category = double({ id: 1, name: "Variant category", code: "vc" })
      variant_brand = double({ id: 1, name: "Variant brand" })
      variant = double({ id: "1", sku: "001", variant_category: variant_category, variant_brand: variant_brand })
      product_category = double({ name: "Product category" })
      product = double({ name: "product", product_category: product_category, variants: [variant] })

      CustomGrape::Data.fetch("ProductEntity").children_entities[:product_category] = {
        name: :product_category,
        entity: ProductCategoryEntity,
        includes: true,
        only: nil,
        except: nil
      }
      CustomGrape::Data.fetch("ProductEntity").children_entities[:variants] = product_data_children_entities_variant
      CustomGrape::Data.fetch("VariantEntity").children_entities[:variant_category] = variant_data_children_entities_variant_category
      CustomGrape::Data.fetch("VariantEntity").children_entities[:variant_brand] = {
        name: :variant_brand,
        entity: VariantBrandEntity,
        includes: true,
        only: nil,
        except: nil
      }

      @json = ProductEntity.represent(product, represent_options).as_json
    end

    it "get correct result" do
      expect(@json).to eq({
        name: "product",
        product_category: {
          name: "Product category"
        },
        variants: [{
          id: "1",
          sku: "001",
          variant_category: {
            id: 1,
            name: "Variant category",
            code: "vc"
          },
          variant_brand: {
            id: 1,
            name: "Variant brand"
          }
        }]
      })
    end

    context "when represent_options except variant_category id" do
      let(:represent_options) { { except: [variants: [variant_category: [:id]]] } }

      it "get correct result" do
        expect(@json).to eq({
          name: "product",
          product_category: {
            name: "Product category"
          },
          variants: [{
            id: "1",
            sku: "001",
            variant_category: {
              name: "Variant category",
              code: "vc"
            },
            variant_brand: {
              id: 1,
              name: "Variant brand"
            }
          }]
        })
      end

      context "when product data children entities variant except variant_category sku" do
        let(:product_data_children_entities_variant_except) { [variant_category: [:code]] }

        it "get correct result" do
          expect(@json).to eq({
            name: "product",
            product_category: {
              name: "Product category"
            },
            variants: [{
              id: "1",
              sku: "001",
              variant_category: {
                name: "Variant category"
              },
              variant_brand: {
                id: 1,
                name: "Variant brand"
              }
            }]
          })
        end
      end
    end

    context "when represent_options only variants" do
      let(:represent_options) { { only: [variants: [:id, :sku, variant_category: [:id, :name]] ] } }

      it "get correct result" do
        expect(@json).to eq({
          variants: [{
            id: "1",
            sku: "001",
            variant_category: {
              id: 1,
              name: "Variant category"
            }
          }]
        })
      end

      context "when product data children entities variant except variant_category sku" do
        let(:product_data_children_entities_variant_only) { [:sku, variant_category: [:name]] }

        it "get correct result" do
          expect(@json).to eq({
            variants: [{
              sku: "001",
              variant_category: {
                name: "Variant category"
              }
            }]
          })
        end
      end
    end

    context "when variant except variant_category" do
      let(:product_data_children_entities_variant_except) { [:variant_category] }

      it "get correct result" do
        expect(@json).to eq({
          name: "product",
          product_category: {
            name: "Product category"
          },
          variants: [{
            id: "1",
            sku: "001",
            variant_brand: {
              id: 1,
              name: "Variant brand"
            }
          }]
        })
      end
    end

    context "when variant only variant_category" do
      let(:product_data_children_entities_variant_only) { [:sku] }

      it "get correct result" do
        expect(@json).to eq({
          name: "product",
          product_category: {
            name: "Product category"
          },
          variants: [{
            sku: "001"
          }]
        })
      end
    end
  end

  describe ".includes" do
    let(:includes_options) { {} }

    before do
      CustomGrape::Data.fetch("ProductEntity").children_entities[:product_category] = {
        name: :product_category,
        entity: ProductCategoryEntity,
        includes: true,
        only: nil,
        except: nil
      }

      CustomGrape::Data.fetch("ProductEntity").children_entities[:variants] = product_data_children_entities_variant
      CustomGrape::Data.fetch("VariantEntity").children_entities[:variant_category] = variant_data_children_entities_variant_category

      @array = ProductEntity.includes(includes_options)
    end

    it "get correct result" do
      expect(@array).to eq([{ product_category: [] }, variants: [{ variant_category: [] }, { variant_brand: [] }]])
    end

    context "when includes_options except variants" do
      let(:includes_options) { { except: [:variants] } }

      it "get correct result" do
        expect(@array).to eq([product_category: []])
      end
    end

    context "when includes_options except variant_category" do
      let(:includes_options) { { except: [variants: [:variant_category]] } }

      it "get correct result" do
        expect(@array).to eq([{ product_category: [] }, variants: [{ variant_brand: [] }]])
      end
    end

    context "when includes_options only variants" do
      let(:includes_options) { { only: [:variants] } }

      it "get correct result" do
        expect(@array).to eq([variants: [{ variant_category: [] },  { variant_brand: [] }]])
      end
    end

    context "when includes_options only variant_category" do
      let(:includes_options) { { only: [variants: [:variant_category]] } }

      it "get correct result" do
        expect(@array).to eq([variants: [variant_category: []]])
      end
    end
  end
end
