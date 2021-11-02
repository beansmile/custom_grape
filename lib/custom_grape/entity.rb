module CustomGrape
  class Entity < Grape::Entity
    def self.inherited(subclass)
      CustomGrape::Includes.build(subclass.name)

      super
    end

    def self.custom_expose(*args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      custom_options = {
        includes: options.delete(:includes),
        except: options.delete(:except),
        only: options.delete(:only)
      }

      raise ArgumentError, "使用only或except参数时不能同时传block参数" if block_given? && (custom_options[:only] || custom_options[:except])

      options = merge_options(options)

      raise ArgumentError, "只能传一个属性" if args.size > 1

      attribute = args[0]
      options[:documentation] ||= {}

      begin
        if model = fetch_model
          custom_grape_includes_object = CustomGrape::Includes.fetch(name)

          if custom_options[:includes]
            custom_grape_includes_object.includes[attribute] = custom_options[:includes].is_a?(Array) ? custom_options[:includes] : [custom_options[:includes]]
          end

          # 关联关系
          if reflection = model.reflect_on_association(attribute)
              options[:documentation][:is_array] = true
            if reflection.is_a?(ActiveRecord::Reflection::HasManyReflection)
              options[:documentation][:type] ||= Array[String, Hash]
            end

            if reflection.class_name == "ActiveStorage::Attachment"
              options[:documentation][:coerce_with] ||= ->(val) {
                case val
                when String
                  val
                when Hash
                  val[:signed_id]
                when Array
                  val.map { |v| v.is_a?(String) ? v : v[:signed_id] }
                end
              }
            end

            unless options[:using]
              array = reflection.klass.name.split("::")
              array[-1] = "Simple#{array[-1]}"

              options[:using] = "#{entity_namespace}::#{array.join("::")}".constantize
            end

            options[:documentation][:type] ||= options[:using]

            unless custom_options[:includes]
              custom_grape_includes_object.children_includes[attribute] = {
                entity_name: options[:using].is_a?(String) ? options[:using] : options[:using].name,
              }
            end

            custom_grape_includes_object.only[attribute] = custom_options[:only] if custom_options[:only]
            custom_grape_includes_object.except[attribute] = custom_options[:except] if custom_options[:except]
          # enum
          elsif model.defined_enums[attribute.to_s]
            options[:documentation][:type] ||= String
            options[:documentation][:values] ||= model.send(attribute.to_s.pluralize).keys + [""]

            unless options[:documentation][:desc]
              enums_desc = model.send(attribute.to_s.pluralize).keys.map { |key| "#{key}为#{model.human_attribute_name("#{attribute}.#{key}")}" }.join("，")
              options[:documentation][:desc] = "#{model.human_attribute_name(attribute)}。#{enums_desc}"
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

          raise ArgumentError, "only或except参数必须结合using使用" if options[:using].nil? && (custom_options[:only] || custom_options[:except])
        end
      rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
        # do nothing
      end

      if custom_options[:except] || custom_options[:only]
        options_using = options.delete(:using)

        expose(attribute, options) do |object, opts|
          except_attrs = nil

          attr_path_dup = opts.opts_hash[:attr_path].dup.pop

          # except取并集
          if opts.instance_variable_get("@has_except") || custom_options[:except]
            except_attrs = (opts.except_fields&.[](attr_path_dup) || []) | (custom_options[:except] || [])
          end

          # only取交集
          only_attrs = if opts.instance_variable_get("@has_only") && custom_options[:only]
                         if opts.only_fields[attr_path_dup] == true
                           custom_options[:only]
                         else
                           opts.only_fields[attr_path_dup] & custom_options[:only]
                         end
                       elsif opts.instance_variable_get("@has_only")
                         opts.only_fields[attr_path_dup] == true ?  nil : opts.only_fields[attr_path_dup]
                       elsif custom_options[:only]
                         custom_options[:only]
                       else
                         nil
                       end

          options_using.represent(object.send(attribute), opts.merge(only: only_attrs, except: except_attrs))
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
  end
end
