module CustomGrape
  class Entity < Grape::Entity
    def self.expose_attached(attribute, options = {})
      expose attribute, { using: CustomGrape::Entities::ActiveStorageAttached }.reverse_merge(options) do |resource|
        attached = resource.send(attribute)

        if attached.is_a?(ActiveStorage::Attached::One)
          attached.attached? ? attached : nil
        else
          attached
        end
      end
    end

    class_attribute :documentation_of_params
    self.documentation_of_params ||= {}

    # 排除 documentation 里面的 example，否则作为 params 会报错
    def self.documentation_extract(*attrs)
      documentation.dup.extract!(*attrs).merge(documentation_of_params.dup.extract!(*attrs)).map do |k, v|
        [k, v.except(:example)]
      end.to_h
    end

    def self.doc_for_params(*args, &block)
      options = merge_options(args.last.is_a?(Hash) ? args.pop : {})

      self.documentation_of_params[args.first] = guess_type(args.first, options) if options[:documentation]
    end

    def self.guess_model
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

    def self.guess_desc(attribute, options)
      # 如果没有 documentation.type，尝试根据 I18n 来设置文档
      return if options.dig(:documentation, :desc)

      model = guess_model

      return options if model.nil?

      options[:documentation] ||= {}

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

      options
    end

    def self.guess_type(attribute, options)
      # 如果没有 documentation.type，尝试根据数据库的类型来设置文档
      return if options.dig(:documentation, :type)

      model = guess_model

      return options if model.nil?

      if model.attachment_reflections.keys.include?(attribute.to_s)
        type_is_array = model.attachment_reflections[attribute.to_s].is_a? ActiveStorage::Reflection::HasManyAttachedReflection
        if type_is_array
          options[:documentation][:types] = [Array[String], Array[Hash]]
        else
          options[:documentation][:type] = String
        end
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
      # enum 类型在数据库是整型，但是暴露出来是 string
      elsif model.defined_enums[attribute.to_s]
        options[:documentation] ||= {}
        options[:documentation][:values] = model.send(attribute.to_s.pluralize).keys
        options[:documentation][:type] = String
      else
        column = model.columns_hash[attribute.to_s]
        if column
          options[:documentation] ||= {}
          options[:documentation][:type] = {
            primary_key: String,
            string: String,
            text: String,
            integer: Integer,
            bigint: Integer,
            float: Float,
            decimal: BigDecimal,
            numeric: Numeric,
            datetime: DateTime,
            time: Time,
            date: Date,
            binary: String,
            boolean: Grape::API::Boolean
          }[column.type]
        end
      end

      options
    end

    def self.build_exposure_for_attribute(attribute, nesting_stack, options, block)
      begin
        guess_desc(attribute, options)
        guess_type(attribute, options)
      rescue => e
        # 暂时先什么都不处理
      end

      super(attribute, nesting_stack, options, block)
    end
  end
end
