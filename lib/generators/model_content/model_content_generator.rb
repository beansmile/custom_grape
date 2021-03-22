# frozen_string_literal: true

class ModelContentGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  # 先把rails g model创建的belongs_to关联关系删除了
  def delete_belongs_to_associations
    gsub_file model_path, /.*belongs_to.*$/, ""
  end

  def generate_rules
    inject_into_file model_path, after: "< ApplicationRecord\n" do
      <<-CONTENT.strip_heredoc.indent(2)
        # constants

        # concerns

        # attr related macros

        # association macros

        # validation macros

        # callbacks

        # other macros

        # scopes

        # class methods

        # instance methods
      CONTENT
    end
  end

  def generate_has_many_associations
    (db_connection.tables - [table_name]).each do |table|
      db_connection.foreign_keys(table).each do |foreign_key_definition|
        next unless foreign_key_definition.to_table == table_name

        columns = db_connection.columns(table).delete_if { |column| column.name.in?(["id", "created_at", "updated_at"]) }

        # 判断是否与中间表的特征相似
        if columns.count == 2 && columns.all? { |column| column.name.end_with?("_id") }
          begin
            table.singularize.classify.constantize

            association_name = foreign_key_definition.from_table
            through_association_name = db_connection.foreign_keys(foreign_key_definition.from_table).detect { |foreign_key_definition| foreign_key_definition.to_table != table }.to_table

            inject_into_file model_path, after: "# association macros\n" do
              <<-CONTENT.strip_heredoc.indent(2)
                has_many :#{association_name}, dependent: :destroy
                has_many :#{through_association_name}, through: :#{association_name}
              CONTENT
            end
          rescue NameError
            inject_into_file model_path, after: "# association macros\n" do
              <<-CONTENT.strip_heredoc.indent(2)
                has_and_belongs_to_many :#{foreign_key_definition.from_table}
              CONTENT
            end
          end
        else
          inject_into_file model_path, after: "# association macros\n" do
            <<-CONTENT.strip_heredoc.indent(2)
              has_many :#{foreign_key_definition.from_table}, dependent: :restrict_with_error
              # accepts_nested_attributes_for :#{foreign_key_definition.from_table}, allow_destroy: true
            CONTENT
          end
        end
      end
    end
  end

  def generate_belongs_to_associations
    # 通过同时拥有_type和_id结尾这一条规则来获取多态的belongs_to关联关系
    db_connection.columns(table_name).each do |column|
      next unless column.name.end_with?("_id")

      association_name = column.name.split("_id")[0]

      next unless polymorphism_type_column = db_connection.columns(table_name).detect { |column| column.name == "#{association_name}_type" }

      array = ["belongs_to :#{association_name}"]
      array = ["belongs_to :#{association_name}, polymorphic: true"]

      array << "optional: true" if column.null || polymorphism_type_column.null

      full_association_str = array.join(", ")

      inject_into_file model_path, after: "# association macros\n" do
        <<-CONTENT.strip_heredoc.indent(2)
          #{full_association_str}
        CONTENT
      end
    end

    # 通过数据库的外键获取belongs_to关联关系
    db_connection.foreign_keys(table_name).each do |foreign_key_definition|
      association_name = foreign_key_definition.options[:column].humanize(capitalize: false).gsub(" ", "_")

      array = ["belongs_to :#{association_name}"]
      array << "class_name: \"#{foreign_key_definition.to_table.classify}\"" if foreign_key_definition.options[:column] != foreign_key_definition.to_table.singularize.foreign_key
      array << "counter_cache: true" if db_connection.columns(foreign_key_definition.to_table).any? { |column| column.name == "#{table_name}_count" }

      column = ActiveRecord::Base.connection.columns(table_name).detect { |column| column.name == foreign_key_definition.options[:column] }

      array << "optional: true" if column.null

      base_association_str = array[0]
      full_association_str = array.join(", ")

      # 如果对应model中已存在对应的belongs_to方法，则替换
      if File.readlines(model_path).grep(/#{base_association_str}/).any?
        gsub_file model_path, /#{base_association_str}.*$/, full_association_str
      # 如果对应model已定义过belongs_to方法，但不是定义在model文件中（可能include或继承了其他类），则不做任何处理
      # elsif model.reflect_on_all_associations(:belongs_to).any? { |reflection| reflection.name.to_s == association_name }
        # next
      else
        inject_into_file model_path, after: "# association macros\n" do
          <<-CONTENT.strip_heredoc.indent(2)
            #{full_association_str}
          CONTENT
        end
      end
    end
  end

  private
  def model
    @model ||= file_name.classify.constantize
  end

  def table_name
    @table_name ||= model.table_name
  end

  def model_path
    @model_path ||= "app/models/#{model.name.underscore}.rb"
  end

  def db_connection
    @db_connection ||= ActiveRecord::Base.connection
  end
end
