module CustomGrape
  class Entity < Grape::Entity
    extend Util

    mattr_accessor :includes_cache, default: {}
    mattr_accessor :only_cache, default: {}

    def self.inherited(subclass)
      data = CustomGrape::Data.build(subclass.name)

      if superclass_data = CustomGrape::Data.fetch(name)
        data.extra = superclass_data.extra.dup
      end

      super
    end

    def self.use_includes_cache
      Rails.env.production? || Rails.env.staging?
    end

    def self.use_only_cache
      Rails.env.production? || Rails.env.staging?
    end

    def self.includes_cache_key(options = {})
      signature = ActiveSupport::Digest.hexdigest(options.sort.to_s)
      "custom_grape:includes:#{name.underscore}-#{signature}".to_sym
    end

    def self.only_cache_key(options = {})
      signature = ActiveSupport::Digest.hexdigest(options.sort.to_s)
      "custom_grape:only:#{name.underscore}-#{signature}".to_sym
    end

    def self.includes(options = {})
      data = includes_cache[includes_cache_key(options)] if use_includes_cache

      return data if data

      includes_cache[includes_cache_key(options)] = CustomGrape::Data.fetch(name)&.fetch_includes(options) || []
    end

    def self.only(options = {})
      data = only_cache[only_cache_key(options)] if use_only_cache

      return data if data

      only_array = options[:only_array]
      except_array = options[:except_array]
      extra = CustomGrape::Data.fetch(name).extra
      only_cache[only_cache_key(options)] = root_exposures.inject([]) do |array, exposure|
        key = exposure.key
        flag = true
        extra_only_array = nil
        extra_except_array = nil

        if only_array
          flag = only_array.any? do |element|
            if element.is_a?(Hash)
              element.any? do |k, v|
                if k.to_s == key.to_s
                  extra_only_array = v

                  true
                else
                  false
                end
              end
            else
              element.to_s == key.to_s
            end
          end
        end

        if flag && except_array
          flag = !except_array.any? do |element|
            if element.is_a?(Hash)
              element.each do |k, v|
                if k.to_s == key.to_s
                  extra_except_array = v

                  break
                end
              end

              false
            else
              element.to_s == key.to_s
            end
          end
        end

        if flag
          if data = extra[key]
            if data[:entity]
              array << { key => data[:entity].only(only_array: merge_only(data[:only], extra_only_array), except_array: merge_except(data[:except], extra_except_array)) }
            else
              array << key
            end
          else
            array << key
          end
        end

        array
      end
    end

    def self.custom_represent(objects, options = {})
      # TODO cache

      new_options = options.merge(only: only(only_array: options[:only]))

      represent(objects, new_options)
    end

    def self.use_cache
      false
    end

    def self.cache_key(objects, options = {})
      # TODO cache
    end

    def self.custom_unexpose(*attributes)
      custom_grape_data_object = CustomGrape::Data.fetch(name)

      attributes.each do |attribute|
        custom_grape_data_object.extra.delete(attribute)
      end

      unexpose(attributes)
    end

    def self.custom_expose(*args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      custom_expose_options = {
        includes: options.delete(:includes),
        except: options.delete(:except),
        only: options.delete(:only)
      }

      options = merge_options(options)

      raise ArgumentError, "只能传一个属性" if args.size > 1

      attribute = args[0]
      as_name = options[:as] || attribute
      options[:documentation] ||= {}

      custom_grape_data_object = CustomGrape::Data.fetch(name)

      begin
        if model = fetch_model
          # 关联关系
          if reflection = model.reflect_on_association(attribute)
            options[:documentation][:is_array] = true if reflection.is_a?(ActiveRecord::Reflection::HasManyReflection)

            if reflection.class_name == "ActiveStorage::Attachment"
              if reflection.is_a?(ActiveRecord::Reflection::HasManyReflection)
                options[:documentation][:type] ||= Array[String, Hash]
                options[:documentation][:coerce_with] ||= -> (vals) do
                  vals.map { |val| val.is_a?(String) ? val : val[:signed_id] }
                end
              else
                options[:documentation][:coerce_with] ||= -> (val) do
                  val.is_a?(String) ? val : val[:signed_id]
                end
              end
            end

            # 如未传using，则自动生成using
            if !reflection.polymorphic? && !options[:using]
              array = reflection.klass.name.split("::")
              array[-1] = "Simple#{array[-1]}"

              options[:using] = "#{entity_namespace}::#{array.join("::")}".constantize
            end

            if options[:using]
              # 把using常量化
              options[:using] = options[:using].constantize if options[:using].is_a?(String)
              custom_grape_data_object.extra[as_name] = {
                entity: options[:using],
                includes: { attribute => options[:using] },
                only: custom_expose_options[:only],
                except: custom_expose_options[:except]
              }
            elsif reflection.polymorphic?
              custom_grape_data_object.extra[as_name] = {
                entity: nil,
                includes: attribute,
                only: custom_expose_options[:only],
                except: custom_expose_options[:except]
              }
            end

            options[:documentation][:type] ||= options[:using]

          # enum
          elsif model.defined_enums[attribute.to_s]
            options[:documentation][:type] ||= String
            options[:documentation][:values] ||= model.send(attribute.to_s.pluralize).keys + [""]

            unless options[:documentation][:desc]
              enums_desc = model.send(attribute.to_s.pluralize).keys.map { |key| "#{key}为#{model.human_attribute_name("#{attribute}.#{key}")}" }.join("，")
              options[:documentation][:desc] = "#{model.human_attribute_name(attribute)}。#{enums_desc}"
            end
          end

          if custom_expose_options[:includes]
            if custom_grape_data_object.extra[as_name]
              custom_grape_data_object.extra[as_name][:includes] = custom_expose_options[:includes]
            else
              custom_grape_data_object.extra[as_name] = {
                entity: nil,
                includes: custom_expose_options[:includes],
                only: nil,
                except: nil
              }
            end
          end

          column = model.columns_hash[attribute.to_s]

          unless options[:documentation][:type]
            options[:documentation][:type] = {
              integer: Integer,
              bigint: Integer,
              float: Float,
              decimal: BigDecimal,
              numeric: Numeric,
              datetime: DateTime,
              time: Time,
              date: Date,
              boolean: Grape::API::Boolean
            }[column&.type] || String
          end

          unless options[:documentation][:desc]
            if column
              options[:documentation][:desc] = model.human_attribute_name(column.name)
            elsif model.instance_methods.include?(attribute)
              options[:documentation][:desc] = model.human_attribute_name(attribute)
            end
          end
        end
      rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
        # do nothing
      end

      if reflection&.polymorphic? && !block_given?
        expose(attribute, options) do |object, opts|
          inside_using = polymorphic_using_entity_class(reflection)

          inside_using.custom_represent(object.send(attribute), opts) if object.send(attribute)
        end
      else
        expose(attribute, options, &block)
      end
    end

    def self.entity_namespace
      self.to_s.split("::")[0..1].join("::")
    end

    def self.fetch_model
      begin
        model_name = self.to_s.split("::")[2..-1].join("::").singularize

        model = Object.const_get(model_name)
      rescue NameError => e
        # 可能有一个 User entity，还有一个 UserDetail entity 表示更详细的信息
        namespaces = model_name.split("::")[0..-2]
        model_name = model_name.split("::")[-1]

        if model_name.match(/.*Detail$/)
          model_name = (namespaces + [model_name.slice(0..-7)]).join("::")

          model = Object.const_get(model_name)
        elsif model_name.match(/^Simple.*$/)
          model_name = (namespaces + [model_name.slice(6..-1)]).join("::")

          model = Object.const_get(model_name)
        end
      rescue StandardError => e
        # 什么都不处理
      end

      model
    end

    def polymorphic_using_entity_class(reflection)
      array = object.send(reflection.foreign_type).split("::")
      array[-1] = "Simple#{array[-1]}"

      "#{self.class.entity_namespace}::#{array.join("::")}".constantize
    end
  end
end
