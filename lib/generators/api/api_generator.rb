# frozen_string_literal: true

class APIGenerator < Rails::Generators::NamedBase
  def self.namespace(name = nil)
    @namespace ||= "api"
  end

  argument :namespace, required: true, desc: "API namespace, e.g. AppAPI"

  source_root File.expand_path("templates", __dir__)

  def create_entity
    create_entity_file
  end

  def create_belongs_to_entity
    belongs_to_associations.each do |association|
      unless ("#{namespace_classify}::Entities::#{simple_entity_name(association.klass)}".constantize rescue nil)
        create_entity_file(association.klass)
      end
    end
  end

  def create_api
    content = <<~CONTENT
      # frozen_string_literal: true

      class #{namespace_classify}::V1::#{resource_class.name.split("::")[-1].pluralize} < API
        include Grape::Kaminari

        apis :index, :show, :create, :update, :destroy, {
          resource_class: #{resource_class.name},
          collection_entity: #{namespace_classify}::Entities::#{resource_class.name.split("::")[-1]},
          resource_entity: #{namespace_classify}::Entities::#{resource_class.name.split("::")[-1]}Detail,
          # find_by_key: :id
          # skip_authentication: false,
          # belongs_to: :category,
          # namespace: :mine
        } do
          helpers do
            params :index_params do
    CONTENT

    string_columns.each { |column| content += " " * 8 + "optional :#{column.name}_cont, @api.resource_entity.documentation[:#{column.name}]\n" }
    enum_columns.each { |column| content += " " * 8 + "optional :#{column.name}_eq, @api.resource_entity.documentation[:#{column.name}]\n" }
    belongs_to_associations.each { |association| content += " " * 8 + "optional :#{association.foreign_key}_eq, @api.resource_entity.documentation[:#{association.name}]\n" }
    boolean_columns.each { |column| content += " " * 8 + "optional :#{column.name}_eq, @api.resource_entity.documentation[:#{column.name}]\n" }
    datetime_columns.each do |column|
      content += " " * 8 + "optional :#{column.name}_gteq_datetime, @api.resource_entity.documentation[:#{column.name}]\n"
      content += " " * 8 + "optional :#{column.name}_lteq_datetime, @api.resource_entity.documentation[:#{column.name}]\n"
    end

    content += <<~CONTENT.strip_heredoc.indent(6)
            end

            params :create_params do
    CONTENT

    if create_requires_params_columns_names.any?
      content += <<~CONTENT.strip_heredoc.indent(8)
        requires :all, using: @api.resource_entity.documentation.slice(
          #{create_requires_params_columns_names.map { |name| ":#{name}" }.join(",\n  ")}
        )
      CONTENT
    end

    requires_many_attached_associations = many_attached_associations.select do |association|
      resource_class.validators_on(association.name).any? do |validator|
        validator.is_a?(ActiveRecord::Validations::LengthValidator) && (
          (validator.options[:minimum] && validator.options[:minimum] > 0) ||
          (validator.options[:is] && validator.options[:is] > 0)
        )
      end
    end

    requires_many_attached_associations.map do |association|
      content << " " * 8 + "requires :#{association.name}, type: Array[String]\n"
    end

    if create_optional_params_columns_names.any?
      content += <<~CONTENT.strip_heredoc.indent(8)
        optional :all, using: @api.resource_entity.documentation.slice(
          #{create_optional_params_columns_names.map { |name| ":#{name}" }.join(",\n  ")}
        )
      CONTENT
    end

    optional_many_attached_associations = (many_attached_associations - requires_many_attached_associations).map do |association|
      content << " " * 8 + "optional :#{association.name}, type: Array[String]\n"
    end

    content += <<~CONTENT.strip_heredoc.indent(6)
      end

      params :update_params do
    CONTENT

    if update_optional_params_columns_names.any?
      content += <<~CONTENT.strip_heredoc.indent(8)
        optional :all, using: @api.resource_entity.documentation.slice(
          #{update_optional_params_columns_names.map { |name| ":#{name}" }.join(",\n  ")}
        )
      CONTENT
    end

    optional_many_attached_associations = (many_attached_associations - requires_many_attached_associations).map do |association|
      content << " " * 8 + "optional :#{association.name}, type: Array[String]\n"
    end

    content += <<~CONTENT
            end
          end # helpers
        end # apis
      end
    CONTENT

    create_file "#{api_path}/v1/#{collection_name}.rb", content
  end

  # def update_model
    # enum_columns.each do |column|
      # unless resource_class._ransackers[column.name.to_s]
        # inject_into_file model_path, "  ransacker :#{column.name}, formatter: proc { |value| #{column.name.pluralize}[value] }\n", after: "\s# other macros\n"
      # end
    # end
  # end

  def mount_api
    inject_into_file(
      "#{api_path}/v1.rb",
      "\n  mount ::#{namespace_classify}::V1::#{resource_class.name.split("::")[-1].pluralize}",
      before: /\s+add_swagger_documentation/
    )
  end

  private
  def resource_class
    @resource_class ||= file_name.classify.constantize rescue "Bean::#{file_name.classify}".constantize
  end

  def namespace_classify
    @namespace_classify ||= namespace.classify
  end

  def namespace_underscore
    @namespace_underscore ||= namespace.underscore
  end

  def resource_name
    @resource_name ||= resource_class.name.underscore.singularize
  end

  def collection_name
    @collection_name ||= resource_class.name.split("::")[-1].underscore.pluralize
  end

  def api_path
    "app/services/#{namespace_underscore}"
  end

  def model_path
    "app/models/#{resource_name}.rb"
  end

  def simple_entity_name(klass)
    "Simple#{klass.name.split("::")[-1]}"
  end

  def create_entity_file(klass = resource_class)
    content = []
    content << <<~FILE
      # frozen_string_literal: true

      module #{namespace_classify}::Entities
        class #{simple_entity_name(klass)} < ::Entities::Model
          #{simple_entity_expose_columns(klass)}
        end

        class #{klass.name.split("::")[-1]} < #{simple_entity_name(klass)}
        end

        class #{klass.name.split("::")[-1]}Detail < #{klass.name.split("::")[-1]}
    FILE
    content << "    #{detail_entity_expose_columns(klass)}\n" if detail_entity_expose_columns(klass).present?
    content << <<~FILE
        end
      end
    FILE

    create_file "#{api_path}/entities/#{klass.name.split("::")[-1].underscore}.rb", content.join
    inject_into_file("#{api_path}/v1.rb", "\n    :#{klass.name.split("::")[-1]},", after: /\s# Entity autoload/)
  end

  def simple_entity_expose_columns(klass = resource_class)
    [
      :string,
      :decimal,
      :float,
      :integer,
      :boolean,
      :date,
      :time,
      :datetime
    ].map { |type| send("#{type}_columns", klass) }.flatten.map do |column|
      "expose :#{column.name}"
    end.join("\n    ")
  end

  def detail_entity_expose_columns(klass = resource_class)
    (
      [
        :text
      ].map { |type| send("#{type}_columns", klass) }.flatten.map do |column|
        "expose :#{column.name}"
      end + (
        one_attached_associations(klass) + many_attached_associations(klass)
      ).map do |association|
        "expose_attached :#{association.name}"
      end + belongs_to_associations(klass).map do |association|
        "expose :#{association.name}, using: #{simple_entity_name(association.klass)}"
      end
    ).join("\n    ")
  end

  def params_columns_types
    [
      :string,
      :decimal,
      :float,
      :integer,
      :boolean,
      :date,
      :time,
      :datetime,
      :text
    ]
  end

  def create_requires_params_columns_names
    @create_requires_params_columns_names ||= (params_columns_types.map { |type| send("#{type}_columns") }.flatten.select do |column|
      resource_class.validators_on(column.name).any? { |validator| validator.is_a?(ActiveRecord::Validations::PresenceValidator) }
    end.map(&:name) + belongs_to_associations.select do |association|
      if association.options[:optional]
        !association.options[:optional]
      elsif association.options[:required]
        association.options[:required]
      else
        true
      end
    end.map(&:foreign_key) + one_attached_associations.select do |association|
      resource_class.validators_on(association.name).any? { |validator| validator.is_a?(AttachPresenceValidator) }
    end.map(&:name)).uniq
  end

  def update_optional_params_columns_names
    @update_optional_params_columns_names ||= (
      params_columns_types.map { |type| send("#{type}_columns") }.flatten.map(&:name) +
      belongs_to_associations.map(&:foreign_key) +
      one_attached_associations.map(&:name)
    ).uniq
  end

  def create_optional_params_columns_names
    @create_optional_params_columns_names ||= update_optional_params_columns_names - create_requires_params_columns_names
  end

  [
    :string,
    :text,
    :float,
    :decimal,
    :time,
    :date,
    :boolean
  ].each do |type|
    define_method "#{type}_columns" do |klass = resource_class|
      klass.columns.select { |column| column.type == type }.sort_by(&:name)
    end
  end

  def integer_columns(klass = resource_class)
    klass.columns.select { |column| column.type == :integer && !column.name.in?(["id"]) }.sort_by(&:name)
  end

  def datetime_columns(klass = resource_class)
    klass.columns.select { |column| column.type == :datetime && !column.name.in?(["created_at", "updated_at"]) }.sort_by(&:name)
  end

  def enum_columns(klass = resource_class)
    klass.columns.select { |column| column.name.to_s.in?(resource_class.defined_enums.keys) }
  end

  def belongs_to_associations(klass = resource_class)
    klass.reflect_on_all_associations(:belongs_to).sort_by(&:name)
  end

  def one_attached_associations(klass = resource_class)
    klass.reflect_on_all_attachments.select { |attachment| attachment.is_a?(ActiveStorage::Reflection::HasOneAttachedReflection) }.sort_by(&:name)
  end

  def many_attached_associations(klass = resource_class)
    klass.reflect_on_all_attachments.select { |attachment| attachment.is_a?(ActiveStorage::Reflection::HasManyAttachedReflection) }.sort_by(&:name)
  end
end
