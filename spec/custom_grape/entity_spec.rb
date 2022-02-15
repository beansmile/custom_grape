require "pry"

RSpec.describe CustomGrape::Entity do
  let(:variant_data_extra_variant_category) do
    {
      entity: VariantCategoryEntity,
      includes: { :variant_category => VariantCategoryEntity },
      only: nil,
      except: nil
    }
  end
  let(:product_data_extra_variant) do
    {
      entity: VariantEntity,
      includes: product_data_extra_variant_includes,
      only: product_data_extra_variant_only,
      except: product_data_extra_variant_except
    }
  end
  let(:product_data_extra_variant_includes) { { :variants => VariantEntity } }
  let(:product_data_extra_variant_only) { nil }
  let(:product_data_extra_variant_except) { nil }

  before :all do
    option_type_entity = Object.const_set("OptionTypeEntity", Class.new(CustomGrape::Entity))
    option_type_entity.expose :id
    option_type_entity.expose :name

    option_value_entity = Object.const_set("OptionValueEntity", Class.new(CustomGrape::Entity))
    option_value_entity.expose :id
    option_value_entity.expose :name
    option_value_entity.expose :option_type, using: OptionTypeEntity

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
    variant_entity.expose :variant_category, using: VariantCategoryEntity
    variant_entity.expose :variant_brand, using: VariantBrandEntity
    variant_entity.expose :option_values, using: OptionValueEntity

    product_category_entity = Object.const_set("ProductCategoryEntity", Class.new(CustomGrape::Entity))
    product_category_entity.expose :name

    product_entity = Object.const_set("ProductEntity", Class.new(CustomGrape::Entity))
    product_entity.expose :name
    product_entity.expose :product_category, using: ProductCategoryEntity
    product_entity.expose :variants, using: VariantEntity

    CustomGrape::Data.collection = {}
    CustomGrape::Data.build("OptionTypeEntity")
    CustomGrape::Data.build("OptionValueEntity")
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
      option_type = double({ id: 1, name: "Color" })
      option_value = double({ id: 1, name: "Yellow", option_type: option_type })
      variant_category = double({ id: 1, name: "Variant category", code: "vc" })
      variant_brand = double({ id: 1, name: "Variant brand" })
      variant = double({ id: "1", sku: "001", variant_category: variant_category, variant_brand: variant_brand, option_values: [option_value] })
      product_category = double({ name: "Product category" })
      product = double({ name: "product", product_category: product_category, variants: [variant] })

      CustomGrape::Data.fetch("ProductEntity").extra[:product_category] = {
        entity: ProductCategoryEntity,
        includes: { :product_category => ProductCategoryEntity },
        only: nil,
        except: nil
      }
      CustomGrape::Data.fetch("ProductEntity").extra[:variants] = product_data_extra_variant
      CustomGrape::Data.fetch("VariantEntity").extra[:variant_category] = variant_data_extra_variant_category
      CustomGrape::Data.fetch("VariantEntity").extra[:variant_brand] = {
        entity: VariantBrandEntity,
        includes: { :variant_brand => VariantBrandEntity },
        only: nil,
        except: nil
      }

      @json = ProductEntity.custom_represent(product, represent_options).as_json
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
          },
          option_values: [
            {
              id: 1,
              name: "Yellow",
              option_type: { id: 1, name: "Color" }
            }
          ]
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
            },
            option_values: [
              {
                id: 1,
                name: "Yellow",
                option_type: { id: 1, name: "Color" }
              }
            ]
          }]
        })
      end

      context "when product data children entities variant except variant_category sku" do
        let(:product_data_extra_variant_except) { [variant_category: [:code]] }

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
              },
              option_values: [
                {
                  id: 1,
                  name: "Yellow",
                  option_type: { id: 1, name: "Color" }
                }
              ]
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
        let(:product_data_extra_variant_only) { [:sku, variant_category: [:name]] }

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
      let(:product_data_extra_variant_except) { [:variant_category] }

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
            },
            option_values: [
              {
                id: 1,
                name: "Yellow",
                option_type: { id: 1, name: "Color" }
              }
            ]
          }]
        })
      end
    end

    context "when variant only variant_category" do
      let(:product_data_extra_variant_only) { [:sku] }

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
      CustomGrape::Data.fetch("ProductEntity").extra[:product_category] = {
        entity: ProductCategoryEntity,
        includes: { :product_category => ProductCategoryEntity },
        only: nil,
        except: nil
      }
      CustomGrape::Data.fetch("ProductEntity").extra[:variants] = product_data_extra_variant
      CustomGrape::Data.fetch("VariantEntity").extra[:variant_category] = variant_data_extra_variant_category
      CustomGrape::Data.fetch("VariantEntity").extra[:variant_brand] = {
        entity: VariantBrandEntity,
        includes: { :variant_brand => VariantBrandEntity },
        only: nil,
        except: nil
      }
      CustomGrape::Data.fetch("VariantEntity").extra[:option_values] = {
        entity: OptionValueEntity,
        includes: { :option_values => OptionValueEntity },
        only: nil,
        except: nil
      }

      CustomGrape::Data.fetch("OptionValueEntity").extra[:option_type] = {
        entity: OptionValueEntity,
        includes: { :option_type => OptionTypeEntity },
        only: nil,
        except: nil
      }

      @array = ProductEntity.includes(includes_options)
    end

    it "get correct result" do
      expect(@array).to eq([{ variants: [{ option_values: [:option_type] }, :variant_brand, :variant_category] }, :product_category])
    end

    context "when custom product_data_extra_variant_includes" do
      let(:product_data_extra_variant_includes) { { :variants => [:variant_brand, :variant_category, option_values: OptionValueEntity] } }

      it "get correct result" do
        expect(@array).to eq([{ variants: [:variant_brand, :variant_category, option_values: [:option_type]] }, :product_category])
      end
    end

    context "when includes_options except variants" do
      let(:includes_options) { { except: [:variants] } }

      it "get correct result" do
        expect(@array).to eq([:product_category])
      end
    end

    context "when includes_options except variant_category" do
      let(:includes_options) { { except: [variants: [:variant_category]] } }

      it "get correct result" do
        expect(@array).to eq([{ variants: [{ option_values: [:option_type] }, :variant_brand] }, :product_category])
      end
    end

    context "when includes_options except option_values" do
      let(:includes_options) { { except: [variants: [:option_values]] } }

      it "get correct result" do
        expect(@array).to eq([{ variants: [:variant_brand, :variant_category] }, :product_category])
      end
    end

    context "when includes_options except option_type" do
      let(:includes_options) { { except: [variants: [option_values: [:option_type]]] } }

      it "get correct result" do
        expect(@array).to eq([{ variants: [:option_values, :variant_brand, :variant_category] }, :product_category])
      end
    end

    context "when includes_options only variants" do
      let(:includes_options) { { only: [:variants] } }

      it "get correct result" do
        expect(@array).to eq([variants: [{ option_values: [:option_type] },:variant_brand, :variant_category]])
      end
    end

    context "when includes_options only variant_category" do
      let(:includes_options) { { only: [variants: [:variant_category]] } }

      it "get correct result" do
        expect(@array).to eq([variants: [:variant_category]])
      end
    end

    context "when includes_options only option_type" do
      let(:includes_options) { { only: [variants: [option_values: [:option_type]]] } }

      it "get correct result" do
        expect(@array).to eq([variants: [option_values: [:option_type]]])
      end
    end
  end
end
