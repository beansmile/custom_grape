module CustomGrape
  class Entity < Grape::Entity
    extend Util

    mattr_accessor :includes_cache, default: {}

    def self.inherited(subclass)
      data = CustomGrape::Data.build(subclass.name)

      if superclass_data = CustomGrape::Data.fetch(name)
        data.extra = superclass_data.extra.dup
      end

      super
    end

    def self.includes(options = {})
      if use_includes_cache
        includes_cache[includes_cache_key(options)] ||= CustomGrape::Data.fetch(name)&.fetch_includes(options) || []
      else
        CustomGrape::Data.fetch(name)&.fetch_includes(options) || []
      end
    end

    def self.use_includes_cache
      Rails.env.production? || Rails.env.staging?
    end

    def self.includes_cache_key(options = {})
      signature = ActiveSupport::Digest.hexdigest(options.sort.to_s)
      "custom_grape:includes:#{name.underscore}-#{signature}".to_sym
    end

    def self.custom_represent(objects, options = {})
      # TODO cache
      represent(objects, options)
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

      raise ArgumentError, "使用only或except参数时不能同时传block参数" if block_given? && (custom_expose_options[:only] || custom_expose_options[:except])

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

      if custom_grape_data_object.extra[as_name] && !block_given?
        inside_using = options.delete(:using)

        expose(attribute, options) do |object, opts|
          inside_using = polymorphic_using_entity_class(reflection) if reflection.polymorphic?

          inside_using.custom_represent(object.send(attribute), custom_options(opts)) if object.send(attribute)
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

    def custom_options(opts)
      attr_path_dup = opts.opts_hash[:attr_path].dup.pop
      if value = CustomGrape::Data.fetch(self.class.name).extra[attr_path_dup]
        except = value[:except]
        only = value[:only]
      end

      merged_except = if opts.instance_variable_get("@has_except") && except
                        if opts.except_fields[attr_path_dup] == true
                          nil
                        else
                          self.class.merge_except(opts.except_fields[attr_path_dup], except)
                        end
                      elsif opts.instance_variable_get("@has_except")
                        opts.except_fields[attr_path_dup] == true ? nil : opts.except_fields[attr_path_dup]
                      else
                        except
                      end

      merged_only = if opts.instance_variable_get("@has_only") && only
                      if opts.only_fields[attr_path_dup] == true
                        only
                      else
                        self.class.merge_only(opts.only_fields[attr_path_dup], only)
                      end
                    elsif opts.instance_variable_get("@has_only")
                      opts.only_fields[attr_path_dup] == true ?  nil : opts.only_fields[attr_path_dup]
                    else
                      only
                    end

      opts.merge(only: merged_only, except: merged_except)
    end
  end
end
