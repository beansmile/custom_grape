# frozen_string_literal: true

class AdminViewTemplateGenerator < Rails::Generators::NamedBase
  RELATION_DISPLAY_COLUMN_NAME = ["name", "title", "label", "nickname", "id"]

  source_root File.expand_path("templates", __dir__)

  def set_i18n
    I18n.locale = :en
  end

  def create_template
    return unless index_api_route

    template("../templates/template.js.tt", "app/services/admin_api/templates/#{collection_name}.js.erb")
  end

  def add_menu
    inject_into_file "#{api_path}/v1/frontend.rb", before: /\s{8}# Routes/  do
      <<~ROUTE.strip_heredoc.indent(8)
        {
          path: "/#{collection_name}",
          name: "#{collection_name}",
          meta: {
            navbar: "el-icon-user",
            title: #{resource_class.name}.model_name.human
          },
          can: current_ability.can?(:read, #{resource_class.name})
        },
      ROUTE
    end
  end

  def add_role_core_config
    path = "config/initializers/role_core.rb"
    if (index_api_route || show_api_route) && create_api_route && update_api_route && destroy_api_route
      inject_into_file path, before: /\s{4}# Permission CRUD set\n/ do
        "    #{resource_name}: \"#{resource_class.name}\",\n"
      end
    else
      inject_into_file path, after: /\s{2}# Permission set\n/  do
        content = []

        content << "group \"#{resource_name}\", model_name: \"#{resource_class.name}\" do"
        content << "  permission :read" if index_api_route || show_api_route
        content << "  permission :create" if create_api_route
        content << "  permission :update" if update_api_route
        content << "  permission :destroy" if destroy_api_route
        content << "end\n"

        content.map { |str| " " * 2 + str }.join("\n")
      end
    end
  end

  def add_locals
    array = []

    form_columns_data.select { |data| data[:form_component] == "enum" }.each do |data|
      array << "#{data[:attribute].pluralize}: #{resource_class.name}.#{data[:attribute].pluralize}.map { |k, _| [k, #{resource_class.name}.human_attribute_name(\"#{data[:attribute]}.#\{k\}\")] }.to_h"
    end

    if array.any?
      inject_into_file "#{api_path}/v1/frontend.rb", after: /\s{10}# Locals\n/ do
        str = <<~CONTENT.strip_heredoc.indent(10)
          def #{collection_name}_locals
            {
              #{array.join("\n")}
            }
          end
        CONTENT
        str + "\n"
      end
    end
  end

  private
  def resource_class
    @resource_class ||= file_name.classify.constantize
  end

  def namespace_classify
    @namespace_classify ||= "AdminAPI"
  end

  def namespace_underscore
    @namespace_underscore ||= namespace_classify.underscore
  end

  def api_path
    @api_path ||= "app/services/#{namespace_underscore}"
  end

  def grape_class
    @grape_class ||= "#{namespace_classify}::V1::#{resource_class.name.pluralize}".constantize
  end

  def resource_name
    @resource_name ||= resource_class.name.underscore.singularize
  end

  def collection_name
    @collection_name ||= resource_class.name.underscore.pluralize
  end

  def index_api_route
    @index_api_route ||= grape_class.routes.detect { |route| route.request_method == "GET" && route.path == "/admin_api/:version/#{collection_name}(.json)" }
  end

  def show_api_route
    @show_api_route ||= grape_class.routes.detect { |route| route.request_method == "GET" && route.path == "/admin_api/:version/#{collection_name}/:id(.json)" }
  end

  def create_api_route
    @create_api_route ||= grape_class.routes.detect { |route| route.request_method == "POST" && route.path == "/admin_api/:version/#{collection_name}(.json)" }
  end

  def update_api_route
    @update_api_route ||= grape_class.routes.detect { |route| route.request_method == "PUT" && route.path == "/admin_api/:version/#{collection_name}/:id(.json)" }
  end

  def destroy_api_route
    @destroy_api_route ||= grape_class.routes.detect { |route| route.request_method == "DELETE" && route.path == "/admin_api/:version/#{collection_name}/:id(.json)" }
  end

  def resource_detail_entity
    @resource_detail_entity ||= "#{namespace_classify}::Entities::#{resource_class}Detail".constantize
  end

  def filter_data
    return @filter_data if @filter_data

    @filter_data = []

    index_api_route.settings[:description][:params].delete_if { |k, v| k.in?(["page", "per_page", "offset", "order_by"]) }.each do |key, options|
      # TODO 找出更好的方法能处理通过title_cont解释得到title的方法
      condition = resource_class.ransack(key => 1).conditions[0]

      next unless condition

      attribute = condition.attributes[0].name

      next unless column = resource_class.columns.detect { |column| column.name == attribute.to_s }
      attribute_type = column.sql_type_metadata.type

      form_component = if resource_class.defined_enums[attribute]
                         "enum"
                       else
                         case attribute_type
                         when :boolean
                           "select"
                         else
                           "input"
                         end
                       end

      @filter_data << {
        prop: key.to_s,
        attribute: attribute,
        label: resource_class.human_attribute_name(attribute),
        attribute_type: attribute_type,
        render_form: true,
        form_component: form_component,
        type: "filter"
      }
    end


    @filter_data
  end

  def filter_array
    return unless index_api_route

    array = []
    array << "["

    filter_data.each do |data|
      array << add_column(data)
    end

    array << "    ]"

    array.join("\n")
  end

  def active_storage_attributes
    @active_storage_attributes ||= resource_detail_entity.documentation.select do |attribute, _|
      resource_class.reflect_on_all_associations.any? { |reflection| reflection.options[:class_name] == "ActiveStorage::Attachment" && reflection.name.to_s.in?(["#{attribute}_attachment", "#{attribute}_attachments"]) }
    end.map { |k, _| k }
  end

  def form_columns_data
    return @form_columns_data if @form_columns_data

    @form_columns_data = []

    @form_columns_data << {
      prop: "id",
      attribute: "id",
      label: resource_class.human_attribute_name(:id),
      sort: true,
      width: 80,
      type: "column"
    }

    string_columns = []
    integer_columns = []
    text_columns = []
    float_columns = []
    boolean_columns = []
    date_columns = []
    datetime_columns = []
    decimal_columns = []
    other_columns = []
    belongs_to_columns = []
    one_attached_columns = []
    many_attached_columns = []

    belongs_to_relations = resource_class.reflect_on_all_associations(:belongs_to).inject({}) { |hash, r| hash[r.foreign_key] = r; hash }

    resource_detail_entity.documentation.each do |attribute, _|
      next if attribute.in?([:id, :created_at, :updated_at])

      column = resource_class.columns.detect { |column| column.name == attribute.to_s }

      if column
        case column.type
        when :string
          string_columns << column.name
        when :integer
          if belongs_to_relations[attribute.to_s]
            belongs_to_columns << column.name
          else
            integer_columns << column.name
          end
        when :text
          text_columns << column.name
        when :decimal
          decimal_columns << column.name
        when :float
          float_columns << column.name
        when :boolean
          boolean_columns << column.name
        when :date
          date_columns << column.name
        when :datetime
          datetime_columns << column.name
        else
          other_columns << column.name
        end
      elsif active_storage_attributes.include?(attribute)
        if attribute.to_s.pluralize == attribute.to_s
          many_attached_columns << attribute
        else
          one_attached_columns << attribute
        end
      end
    end

    # 按属性类型顺序生成
    (
      string_columns +
      decimal_columns +
      float_columns +
      belongs_to_columns +
      integer_columns +
      boolean_columns +
      date_columns +
      datetime_columns +
      other_columns +
      one_attached_columns +
      many_attached_columns +
      text_columns
    ).each do |attribute|
      # TODO 暂时只处理属于model自身的属性和active_storage，不处理关联关系
      column = resource_class.columns.detect { |column| column.name == attribute.to_s }

      flag  = true
      attribute_type = nil
      hide_in_table = false

      if column
        attribute_type = column.sql_type_metadata.type
        hide_in_table = attribute_type == :text
      elsif active_storage_attributes.include?(attribute)
        hide_in_table = attribute.to_s.pluralize == attribute.to_s
      else
        flag = false
      end

      next unless flag

      create_or_update_api_route = create_api_route || update_api_route

      form_component, render_cell_component = if attribute == :email
                                                ["email", nil]
                                              elsif resource_class.defined_enums[attribute.to_s]
                                                ["enum", "enum"]
                                              elsif belongs_to_relation = belongs_to_relations[attribute.to_s]
                                                ["belongs_to", "belongs_to"]
                                              elsif active_storage_attributes.include?(attribute)
                                                ["upload", "attachment"]
                                              else
                                                case attribute_type
                                                when :boolean
                                                  ["switch", "bool"]
                                                when :datetime
                                                  ["input", "time"]
                                                when :date
                                                  ["datePicker", nil]
                                                when :text
                                                  ["textarea", "textarea"]
                                                else
                                                  ["input", nil]
                                                end
                                              end

      render_form = create_or_update_api_route ? create_or_update_api_route.settings[:description][:params].try(:[], attribute.to_s)&.present? : false

      sort = if render_cell_component.in?(["textarea", "attachment", "belongs_to"])
               false
             else
               true
             end

      @form_columns_data << {
        prop: attribute.to_s,
        attribute: attribute.to_s,
        sort: sort,
        render_form: render_form,
        required: render_form ? create_or_update_api_route.settings[:description][:params][attribute.to_s][:required] : false,
        form_component: form_component,
        hide_in_table: hide_in_table,
        render_cell_component: render_cell_component,
        type: "column",
        belongs_to_relation: belongs_to_relation
      }
    end

    ["created_at", "updated_at"].each do |attribute|
      @form_columns_data << {
        prop: attribute,
        attribute: attribute,
        hide_in_table: true,
        render_cell_component: "time",
        type: "column"
      }
    end

    @form_columns_data
  end

  def source_page_props
    array = []
    array << "{"
    array << "      resource: '#{collection_name}',"

    if create_api_route
      array << "      createButtonText: '<%= I18n.t(\"actions.create\", resource: #{resource_class.model_name}.model_name.human) %>',"
      array << "      createPageLocation: { path: '/#{collection_name}/new' }"
    end

    array << "    },"

    array.join("\n")
  end

  def new_config
    "  new: { requestURL: '/#{collection_name}' }," if create_api_route
  end

  def columns_array
    array = []
    array << "["


    form_columns_data.each do |data|
      array << add_column(data)
    end

    array << "      {"
    array << "        prop: 'action',"
    array << "        label: '<%= #{resource_class.name}.human_attribute_name(:action) %>',"
    array << "        width: 100,"
    if show_api_route
      array << " " * 8 + "detail: this.$route.params.pathMatch.match(/\\/\\d+/) ? false : function({ row }) {"
      array << " " * 8 + "  return {"
      array << " " * 8 + "    location: `/#{collection_name}/${row.id}`"
      array << " " * 8 + "  }"
      array << " " * 8 + "},"
    end
    if update_api_route
      array << " " * 8 + "edit: function({ row }) {"
      array << " " * 8 + "  return {"
      array << " " * 8 + "    location: `/#{collection_name}/${row.id}/edit`"
      array << " " * 8 + "  }"
      array << " " * 8 + "},"
    end
    if destroy_api_route
      array << "        delete: {"
      array << "          handler: async ({ row }) => {"
      array << "            await this.$autoLoading(this.$request.delete(`/#{collection_name}/${row.id}`));"
      array << "            this.$message.success(this.$t('删除成功'));"
      array << "            this.$route.params.id ? this.$router.push({ path: '/#{collection_name}' }) : this.fetchData();"
      array << "          }"
      array << "        },"
    end

    extra_put_apis = grape_class.routes.select { |route| route.request_method == "PUT" && route.path != "/admin_api/:version/#{collection_name}/:id(.json)" }

    if extra_put_apis.any?
      array << "        extraAction: (h, { row }) => {"
      array << "          let actions = []\n"

      extra_put_apis.each do |api|
        api_method_name = api.path.split("/")[-1].gsub("(.json)", "")
        js_method_name = api_method_name.camelize(:lower)

        array << <<~CONTENT.strip_heredoc.indent(10)
        if (<%= current_ability.can?(:update, #{resource_class.name}) %>) {
          const #{js_method_name}Text = '<%= I18n.t(actions.#{api_method_name}) %>'

          actions.push({
            text: #{js_method_name}Text,
            handler: async () => {
              await this.$confirm('<%= I18n.t("hints.confirm_to_execute_the_action") %>', #{js_method_name}Text)
              await this.$request.put(`/#{collection_name}/${row.id}/#{api_method_name}`)
              this.$message.success('<%= I18n.t("hints.action_executed_successful") %>');
              this.fetchData();
            }
          })
        }
        CONTENT
      end

      array << "          return actions"
      array << "        }"
    end

    array << "      }"
    array << "    ]"

    array.join("\n")
  end

  def add_column(data)
    array = []

    array << "      {"
    array << "        prop: '#{data[:prop]}',"
    if data[:form_component] == "belongs_to"
      array << "        label: '<%= #{resource_class}.human_attribute_name(:#{data[:belongs_to_relation].name}) %>',"
    else
      array << "        label: '<%= #{resource_class}.human_attribute_name(:#{data[:attribute]}) %>',"
    end
    array << "        width: #{data[:width]}," if data[:width]
    array << "        sort: 'order_by'," if data[:sort]

    if data[:hide_in_table] || data[:hide_in_detail]
      hide_in_array = []
      hide_in_array << "hide-in-table" if data[:hide_in_table]
      hide_in_array << "hide-in-detail" if data[:hide_in_detail]
      action = hide_in_array.map { |str| "'#{str}'" } .join(", ")

      array << "        action: [#{action}],"
    end

    if data[:render_cell_component]
      if respond_to?("#{data[:render_cell_component]}_render_cell", true)
        render_cell_data_array = send("#{data[:render_cell_component]}_render_cell", data).split("\n")
        start_render_cell_data = render_cell_data_array.shift
        start_render_cell_data = render_cell_data_array.pop

        array << "        renderCell: (h, { row }) => {"
        array += render_cell_data_array.map { |str| " " * 8 + str }
        array << "        },"
      else
        array << "        renderCell: '#{data[:render_cell_component]}',"
      end
    end

    if data[:render_form]
      array << "        form: {"
      array << "          required: true," if data[:required]

      if respond_to?("#{data[:form_component]}_form", true)
        form_data_array = send("#{data[:form_component]}_form", data).split("\n")
        start_form_data = form_data_array.shift
        start_form_data = form_data_array.pop

        array += form_data_array.map { |str| " " * 8 + str }
      else
        array << "          component: '#{data[:form_component]}'"
      end

      array << "        }"
    end

    array << "      },"

    array
  end

  def select_form(data)
    <<~FILE
      {
        component: 'select',
        props: {
          defaultValue: '',
          clearable: true,
          options: [{ label: 'True', value: true }, { label: 'False', value: false }]
        }
      }
    FILE
  end

  def textarea_form(data)
    <<~FILE
      {
        component: 'input',
        props: {
          type: 'textarea',
          rows: 10
        }
      }
    FILE
  end

  def upload_form(data)
    <<~FILE
      {
        component: 'upload',
        props: {
          limit: #{data[:attribute] == data[:attribute].pluralize ? 9 : 1},
          hint: '建议尺寸: 147x566'
        }
      }
    FILE
  end

  def email_form(data)
    <<~FILE
      {
        component: 'input',
        props: {
          type: 'email'
        }
      }
    FILE
  end

  def enum_form(data)
    <<~FILE
      {
        component: 'select',
        props: {
          clearable: #{data[:type] == "filter"},
          options: locals._.map(locals.#{data[:attribute].pluralize}, (label, value) => ({ label, value}))
        }
      }
    FILE
  end

  def belongs_to_form(data)
    display_column_name = RELATION_DISPLAY_COLUMN_NAME.detect do |name|
      name.in?(data[:belongs_to_relation].klass.columns.map(&:name))
    end
    belongs_to_model = data[:belongs_to_relation].klass

    <<~FILE
      {
        component: 'select',
        props: {
          xRemotePreload: async () => {
            const { data } = await this.$request.get('/#{belongs_to_model.name.underscore.pluralize}', { params: { per_page: 100 } });
            return data.map(({ id, #{display_column_name} }) => ({ value: id, label: #{display_column_name} }))
          },
          xRemoteSearch: async (keyword) => {
            const params = { #{display_column_name}_cont: keyword };
            const { data } = await this.$request.get('/#{belongs_to_model.name.underscore.pluralize}', { params });
            return data.map(item => ({ value: item.id, label: item.#{display_column_name} }));
          }
        }
      }
    FILE
  end

  def textarea_render_cell(data)
    <<~FILE
      {
        if (!row.#{data[:attribute]}) {
          return '/'
        }
        return h('span', {
          style: "white-space: pre-wrap; word-break: break-all"
        }, row.#{data[:attribute]})
      }
    FILE
  end

  def enum_render_cell(data)
    <<~FILE
      {
        // TODO 调整标签类型
        const type = ['warning', 'success', 'danger', 'info'][Object.keys(locals.#{data[:attribute].pluralize}).indexOf(row.#{data[:attribute]})];
        return h('el-tag', {
          attrs: {
            type: type
          },
        }, locals.#{data[:attribute].pluralize}[row.#{data[:attribute]}])
      }
    FILE
  end

  def belongs_to_render_cell(data)
    display_column_name = RELATION_DISPLAY_COLUMN_NAME.detect do |name|
      name.in?(data[:belongs_to_relation].klass.columns.map(&:name))
    end
    belongs_to_model = data[:belongs_to_relation].klass

    <<~FILE
      {
        if (row.#{data[:attribute]}) {
          const name = row.#{data[:belongs_to_relation].name}.#{display_column_name}
          if (<%= current_ability.can?(:read, #{data[:belongs_to_relation].class_name}) %>) {
            return h('router-link', {
              props: { to: { path : `/#{belongs_to_model.name.underscore.pluralize}/${row.#{data[:belongs_to_relation].foreign_key}}`, } }
            }, name)
          } else {
            return name
          }
        } else {
          return '/'
        }
      }
    FILE
  end

end
