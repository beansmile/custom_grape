module CustomGrape
  class Entity < Grape::Entity
    def self.inherited(subclass)
      CustomGrape::Includes.build(subclass.name)

      super
    end

    def self.custom_expose(*args, &block)
      options = args.last.is_a?(Hash) ? args.pop : {}
      options = merge_options(options)

      raise ArgumentError, "只能传一个属性" if args.size > 1

      attribute = args[0]
      options[:documentation] ||= {}

      begin
        if model = fetch_model
          set_desc(model, attribute, options) unless options[:documentation][:desc]
          set_type(model, attribute, options) unless options[:documentation][:type]
          set_values(model, attribute, options) unless options[:documentation][:values]
          set_coerce_with(model, attribute, options) unless options[:documentation][:coerce_with]

          custom_grape_includes_object = CustomGrape::Includes.fetch(name)

          if reflection = model.reflect_on_association(attribute)
            if reflection.class_name == "ActiveStorage::Attachment"
              options[:using] ||= active_storage_attached_entity_name
              custom_grape_includes_object.includes = custom_grape_includes_object.includes | [{ attribute => :blob }]
            else
              options[:documentation][:is_array] = true if reflection.is_a?(ActiveRecord::Reflection::HasManyReflection)

              options[:using] ||= "#{entity_namespace}::Simple#{reflection.klass}"

              custom_grape_includes_object.children_includes[attribute] = {
                entity_name: options[:using].is_a?(String) ? options[:using] : options[:using].name,
              }
            end
          elsif reflection = model.reflect_on_attachment(attribute)
            options[:using] ||= active_storage_attached_entity_name

            if reflection.is_a?(ActiveStorage::Reflection::HasManyAttachedReflection)
              options[:documentation][:is_array] = true
              array = [{ "#{attribute}_attachments".to_sym => :blob }]
            else
              array = [{ "#{attribute}_attachment".to_sym => :blob }]
            end

            custom_grape_includes_object.includes = custom_grape_includes_object.includes | array
          end
        end
      rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
        # do nothing
      end

      if options[:using] == active_storage_attached_entity_name && !block_given?
        expose(attribute, options) do |resource|
          attached = resource.send(attribute)

          if attached.is_a?(ActiveStorage::Attached::One)
            attached.attached? ? attached : nil
          else
            attached
          end
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

    def self.set_desc(model, attribute, options)
      column = model.columns_hash[attribute.to_s]

      if column
        options[:documentation][:desc] = model.human_attribute_name(column.name)

        if model.defined_enums[attribute.to_s]
          enums_desc = model.send(attribute.to_s.pluralize).keys.map { |key| "#{key}为#{model.human_attribute_name("#{column.name}.#{key}")}" }.join("，")
          options[:documentation][:desc] += "。#{enums_desc}"
        end
      elsif model.instance_methods.include?(attribute)
        options[:documentation][:desc] = model.human_attribute_name(attribute)
      end
    end

    def self.set_type(model, attribute, options)
      options[:documentation][:type] = if reflection = model.reflect_on_attachment(attribute)
                                         reflection.is_a?(ActiveStorage::Reflection::HasManyAttachedReflection) ? Array[String, Hash] : String
                                         # enum 类型在数据库是整型，但是暴露出来是 string
                                       elsif model.defined_enums[attribute.to_s]
                                         String
                                       else
                                         column = model.columns_hash[attribute.to_s]

                                         {
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
    end

    def self.set_values(model, attribute, options)
      if model.defined_enums[attribute.to_s]
        options[:documentation][:values] = model.send(attribute.to_s.pluralize).keys + [""]
      end
    end

    def self.set_coerce_with(model, attribute, options)
      return unless model.reflect_on_association(attribute)

      options[:documentation][:coerce_with] = ->(val) {
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

    def self.active_storage_attached_entity_name
      raise NotImplementedError
    end
  end
end
