# frozen_string_literal: true

class AdminViewGenerator < Rails::Generators::NamedBase
  RELATION_DISPLAY_COLUMN_NAME = ["name", "title", "label", "nickname", "id"]

  source_root File.expand_path("templates", __dir__)

  argument :opts, type: :hash, default: {}

  def set_i18n
    I18n.locale = "zh-CN"
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

  def create_index_page
    return unless index_api_route

    import_data = enum_columns.select { |column| column.name.to_sym.in?(resource_detail_entity.documentation.keys) }

    if import_data.any?
      import_data = [
        "import { #{import_data.map { |column| "#{resource_class.name.underscore}_#{column.name.pluralize.upcase}" }.join(", ")} } from '@/constants';",
          "import _ from 'lodash';"
      ].join("\n")
    end

    array = []
    array << "<template>"
    array << "  <div class=\"page\">"
    array << "    <c-source-page"
    array << "      :table=\"table\""
    array << "      :columns=\"columns\""
    array << "      :filter=\"filter\""
    array << "      :pagination=\"pagination\""
    array << "      resource=\"#{collection_name}\""
    array << "      createButtonText=\"#{I18n.t("actions.new", resource: resource_class.model_name.human)}\"" if create_api_route
    array << "    />"
    array << "  </div>"
    array << "</template>"
    array << ""
    array << "<script>"
    array << "import { Vue, Component } from 'vue-property-decorator';"
    array << "import createColumns from './columns';"
    array << import_data if import_data.present?
    array << ""
    array << "@Component"
    array << "export default class #{resource_class.name.pluralize} extends Vue {"
    array << ""
    array << "  pagination = {}"
    array << ""
    array << "  filter = ["

    string_columns.each do |column|
      next unless "#{column.name}_cont".in?(index_api_route.settings[:description][:params].keys)

      array << "    {"
      array << "      prop: '#{column.name}_cont',"
      array << "      label: '#{resource_class.human_attribute_name(column.name)}',"
      array << "      form: {"
      array << "        component: 'search'"
      array << "       }"
      array << "    },"
    end

    enum_columns.each do |column|
      next unless "#{column.name}_eq".in?(index_api_route.settings[:description][:params].keys)

      array << "    {"
      array << "      prop: '#{column.name}_eq',"
      array << "      label: '#{resource_class.human_attribute_name(column.name)}',"
      array << "      form: {"
      array << "        component: 'select',"
      array << "        props: {"
      array << "          clearable: true,"
      array << "          options: _.map(#{resource_class.name.underscore}_#{column.name.pluralize.upcase}, (label, value) => ({ label, value }))"
      array << "        }"
      array << "      }"
      array << "    },"
    end

    boolean_columns.each do |column|
      next unless "#{column.name}_eq".in?(index_api_route.settings[:description][:params].keys)

      array << "    {"
      array << "      prop: '#{column.name}_eq',"
      array << "      label: '#{resource_class.human_attribute_name(column.name)}',"
      array << "      form: {"
      array << "        component: 'select',"
      array << "        props: {"
      array << "          clearable: true,"
      array << "          options: [{ label: '是', value: true }, { label: '否', value: false }]"
      array << "        }"
      array << "      }"
      array << "    },"
    end

    datetime_columns.each do |column|
      if "#{column.name}_gteq_datetime".in?(index_api_route.settings[:description][:params].keys)
        array << "    {"
        array << "      prop: '#{column.name}_gteq_datetime',"
        array << "      label: '#{resource_class.human_attribute_name(column.name)}大于等于',"
        array << "      form: {"
        array << "        component: 'datePicker'"
        array << "       }"
        array << "    },"
      end

      if "#{column.name}_lteq_datetime".in?(index_api_route.settings[:description][:params].keys)
        array << "    {"
        array << "      prop: '#{column.name}_lteq_datetime',"
        array << "      label: '#{resource_class.human_attribute_name(column.name)}小于等于',"
        array << "      form: {"
        array << "        component: 'datePicker'"
        array << "       }"
        array << "    },"
      end
    end

    array << "  ]"
    array << ""
    array << "  table = {"
    array << "    data: []"
    array << "  };"
    array << ""
    array << "  get columns() {"
    array << "    return createColumns.call(this)"
    array << "  }"
    array << ""
    array << "  async mounted() {"
    array << "    this.fetchData();"
    array << "  }"
    array << ""
    array << "  async fetchData(params = {}) {"
    if opts["belongs_to"]
      array << "    const { data, pagination } = await this.$request.get('/#{collection_name}', { params: { ...this.$route.query, ...params, #{opts["belongs_to"]}_id_eq: this.$route.params.#{opts["belongs_to"]}_id } });"
    else
      array << "    const { data, pagination } = await this.$request.get('/#{collection_name}', { params: { ...this.$route.query, ...params } });"
    end
    array << "    this.table.data = data;"
    array << "    this.pagination = pagination;"
    array << "  }"
    array << "}"
    array << "</script>\n"

    create_file "tmp/#{collection_name}/index.vue", array.join("\n")
  end

  def create_show_page
    return unless show_api_route

    array = []
    array << "<template>"
    array << "  <div class=\"page\">"
    array << "    <c-source-detail"
    array << "      :columns=\"columns\""
    array << "      :data=\"data\""
    array << "      resource=\"#{collection_name}\""
    array << "    />"
    array << "  </div>"
    array << "</template>"
    array << ""
    array << "<script>"
    array << "import { Vue, Component } from 'vue-property-decorator';"
    array << "import createColumns from './columns';"
    array << ""
    array << "@Component"
    array << "export default class #{resource_class.name}Show extends Vue {"
    array << ""
    array << "  data = {}"
    array << ""
    array << "  get columns() {"
    array << "    return createColumns.call(this, {"
    array << "      actionColumn: { detail: false },"
    array << "      detailPage: true,"
    array << "    })"
    array << "  }"
    array << ""
    array << "  mounted() {"
    array << "    this.fetchData();"
    array << "  }"
    array << ""
    array << "  async fetchData() {"
    if opts["belongs_to"]
      array << "    this.data = await this.$request.get(`/#{collection_name}/${this.$route.params.#{resource_name}_id}`);"
    else
      array << "    this.data = await this.$request.get(`/#{collection_name}/${this.$route.params.id}`);"
    end
    array << "  }"
    array << "}"
    array << "</script>\n"

    create_file "tmp/#{collection_name}/show.vue", array.join("\n")
  end

  def create_new_page
    return unless create_api_route

    array = []
    array << "<template>"
    array << "  <div class=\"page\">"
    array << "    <c-source-form"
    array << "      :columns=\"columns\""
    array << "      :data=\"data\""
    array << "      @submit=\"handleCreate\""
    array << "    />"
    array << "  </div>"
    array << "</template>"
    array << ""
    array << "<script>"
    array << "import { Vue, Component } from 'vue-property-decorator';"
    array << "import createColumns from './columns';"
    array << ""
    array << "@Component"
    array << "export default class #{resource_class.name}New extends Vue {"
    array << ""
    array << "  data = {}"
    array << ""
    array << "  get columns() {"
    array << "    return createColumns.call(this);"
    array << "  }"
    array << ""
    array << "  async handleCreate(data) {"
    array << "    const { id } = await this.$autoLoading("
    array << "      this.$request.post('/#{collection_name}', {"
    array << "        ...data,"
    array << "        #{opts["belongs_to"]}_id: this.$route.params.id" if opts["belongs_to"]
    array << "      })"
    array << "    );"
    array << "    this.$message.success('创建成功');"
    if opts["belongs_to"]
      array << "    this.$router.push({ name: '#{collection_name}.show', params: { #{resource_name}_id: id } });"
    else
      array << "    this.$router.push({ name: '#{collection_name}.show', params: { id } });"
    end
    array << "  }"
    array << "}"
    array << "</script>\n"

    create_file "tmp/#{collection_name}/new.vue", array.join("\n")
  end

  def create_edit_page
    return unless update_api_route

    array = []
    array << "<template>"
    array << "  <div class=\"page\">"
    array << "    <c-source-form"
    array << "      :columns=\"columns\""
    array << "      :data=\"data\""
    array << "      @submit=\"handleUpdate\""
    array << "    />"
    array << "  </div>"
    array << "</template>"
    array << ""
    array << "<script>"
    array << "import { Vue, Component } from 'vue-property-decorator';"
    array << "import createColumns from './columns';"
    array << ""
    array << "@Component"
    array << "export default class #{resource_class.name}Edit extends Vue {"
    array << ""
    array << "  data = {}"
    array << ""
    array << "  get columns() {"
    array << "    return createColumns.call(this);"
    array << "  }"
    array << ""
    array << "  async mounted() {"
    if opts["belongs_to"]
      array << "    this.data = await this.$request.get(`/#{collection_name}/${this.$route.params.#{resource_name}_id}`);"
    else
      array << "    this.data = await this.$request.get(`/#{collection_name}/${this.$route.params.id}`);"
    end
    array << "  }"
    array << ""
    array << "  async handleUpdate(data) {"
    if opts["belongs_to"]
      array << "    const id = this.$route.params.#{resource_name}_id;"
    else
      array << "    const id = this.$route.params.id;"
    end
    array << "    await this.$autoLoading("
    array << "      this.$request.put(`/#{collection_name}/${id}`, data)"
    array << "    );"
    array << "    this.$message.success('更新成功');"
    array << "    this.$router.go(-1);"
    array << "  }"
    array << "}"
    array << "</script>\n"

    create_file "tmp/#{collection_name}/edit.vue", array.join("\n")
  end

  def create_route_page
    array = []
    if opts["belongs_to"]
      array << "export default ["
    else
      array << "export default {"
      array << "  path: '',"
      array << "  component: {"
      array << "    template: '<router-view :key=\"$route.fullPath\" />'"
      array << "  },"
      array << "  children: ["
    end

    route_array = []

    if index_api_route && opts["belongs_to"].blank?
      route_array << "{"
      route_array << "  path: '/#{collection_name}',"
      route_array << "  name: '#{collection_name}.index',"
      route_array << "  component: require('./index').default,"
      route_array << "  meta: {"
      route_array << "    title: '#{resource_class.model_name.human}',"
      route_array << "    navbar: 'el-icon-picture-outline',"
      route_array << "    permission: '#{collection_name}.read'"
      route_array << "  }"
      route_array << "},"
    end

    if create_api_route
      route_array << "{"
      if opts["belongs_to"]
        route_array << "  path: '/#{opts["belongs_to"].pluralize}/:id/#{collection_name}/new',"
      else
        route_array << "  path: '/#{collection_name}/new',"
      end
      route_array << "  name: '#{collection_name}.new',"
      route_array << "  component: require('./new').default,"
      route_array << "  meta: {"
      route_array << "    title: '#{I18n.t("actions.new", resource: resource_class.model_name.human)}',"
      route_array << "    permission: '#{collection_name}.create'"
      route_array << "  }"
      route_array << "},"
    end

    if show_api_route
      route_array << "{"
      if opts["belongs_to"]
        route_array << "  path: '/#{opts["belongs_to"].pluralize}/:id/#{collection_name}/:#{resource_name}_id',"
      else
        route_array << "  path: '/#{collection_name}/:id',"
      end
      route_array << "  name: '#{collection_name}.show',"
      route_array << "  component: require('./show').default,"
      route_array << "  meta: {"
      route_array << "    title: '#{I18n.t("actions.show", resource: resource_class.model_name.human)}',"
      route_array << "    permission: '#{collection_name}.read'"
      route_array << "  }"
      route_array << "},"
    end

    if update_api_route
      route_array << "{"
      if opts["belongs_to"]
        route_array << "  path: '/#{opts["belongs_to"].pluralize}/:id/#{collection_name}/:#{resource_name}_id/edit',"
      else
        route_array << "  path: '/#{collection_name}/:id/edit',"
      end
      route_array << "  name: '#{collection_name}.edit',"
      route_array << "  component: require('./edit').default,"
      route_array << "  meta: {"
      route_array << "    title: '#{I18n.t("actions.edit", resource: resource_class.model_name.human)}',"
      route_array << "    permission: '#{collection_name}.update'"
      route_array << "  }"
      route_array << "},"
    end

    array += route_array.map { |str| (" " * (opts["belongs_to"] ? 2 : 4)) + str }

    if opts["belongs_to"]
      array << "]"
    else
      array << "  ]"
      array << "}"
    end

    create_file "tmp/#{collection_name}/route.js", array.join("\n")
  end

  def create_columns
    template("../templates/columns.js.tt", "tmp/#{collection_name}/columns.js")
  end

  def puts_messages
    puts <<~FILE
      #########################################################################
      文件已生成，已存放到以下目录
      tmp/#{collection_name}

      把下面的内容复制到src/router.js的routes变量里
      require('@/views/#{collection_name}/route').default

      把下面的内容复制到src/constants.js
    FILE

    enum_columns.select { |column| column.name.to_sym.in?(resource_detail_entity.documentation.keys) }.map { |column| column.name }.each do |attribute|
      puts "export const #{resource_class.name.underscore}_#{attribute.pluralize.upcase} = {"
      resource_class.send(attribute.pluralize).keys.each do |key|
        puts "  #{key}: '#{resource_class.human_attribute_name("#{attribute}.#{key}")}',"
      end
      puts "}"
      puts ""
    end
    puts "#########################################################################"
  end

  private
  def resource_class
    @resource_class ||= file_name.classify.constantize rescue "Bean::#{file_name.classify}".constantize
  end

  def namespace_classify
    @namespace_classify ||= "AdminAPI"
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

  def columns_import
    array = []
    enum_data_array = enum_columns.select { |column| column.name.to_sym.in?(resource_detail_entity.documentation.keys) }

    array << "import { #{enum_data_array.map { |column| "#{resource_class.name.underscore}_#{column.name.pluralize.upcase}" }.join(", ")}, TAG_TYPE } from '@/constants';" if enum_data_array.any?
    array << "import { permissionService } from 'beans-admin-plugin';" if belongs_to_associations.any? { |association| association.foreign_key.to_sym.in?(resource_detail_entity.documentation.keys) }

    array.join("\n")
  end

  def render_form_for_attribute?(attribute)
    create_or_update_api_route = create_api_route || update_api_route
    create_or_update_api_route ? create_or_update_api_route.settings[:description][:params].try(:[], attribute.to_s)&.present? : false
  end

  def required_for_attribute?(attribute)
    create_or_update_api_route = create_api_route || update_api_route
    create_or_update_api_route.settings[:description][:params][attribute.to_s][:required]
  end

  def columns_array
    array = []
    resource_detail_entity_attributes = resource_detail_entity.documentation.keys

    array << "["
    array << "    {"
    array << "      prop: 'id',"
    array << "      label: '#{resource_class.human_attribute_name(:id)}',"
    array << "      width: 80,"
    array << "      sort: 'order_by',"
    array << "    },"

    string_columns.each do |column|
      next unless column.name.to_sym.in?(resource_detail_entity_attributes)

      array << "    {"
      array << "      prop: '#{column.name}',"
      array << "      label: '#{resource_class.human_attribute_name(column.name)}',"
      array << "      sort: 'order_by',"

      if render_form_for_attribute?(column.name)
        array << "      form: {"
        array << "        required: true," if required_for_attribute?(column.name)
        array << "        component: 'input',"
        array << "      },"
      end

      array << "    },"
    end

    belongs_to_associations.each do |association|
      next unless association.foreign_key.to_sym.in?(resource_detail_entity_attributes)

      display_column_name = RELATION_DISPLAY_COLUMN_NAME.detect do |name|
        name.in?(association.klass.columns.map(&:name))
      end

      array << "    {"
      array << "      prop: '#{association.foreign_key}',"
      array << "      label: '#{resource_class.human_attribute_name(association.name)}',"
      array << "      renderCell: (h, { row }) => {"
      array << "        if (row.#{association.name}) {"
      array << "          const name = row.#{association.name}.#{display_column_name}"
      array << "            if (permissionService.hasPermission('#{association.class_name.underscore.pluralize}.read')) {"
      array << "              return <c-link-button to={{ name: '#{association.name.to_s.pluralize}.show', params: { id: row.#{association.foreign_key} } }}>{name}</c-link-button>"
      array << "            } else {"
      array << "              return name"
      array << "            }"
      array << "        } else {"
      array << "          return '/'"
      array << "        }"
      array << "      },"

      if render_form_for_attribute?(association.foreign_key)
        array << "      form: {"
        array << "        required: true," if required_for_attribute?(association.foreign_key)
        array << "        component: 'select',"
        array << "        props: {"
        array << "          xRemotePreload: async () => {"
        array << "            const { data } = await this.$request.get('/#{association.class_name.underscore.pluralize}', { params: { per_page: 100 } });"
        array << "            return data.map(({ id, #{display_column_name} }) => ({ value: id, label: #{display_column_name} }));"
        array << "          },"
        array << "          xRemoteSearch: async (keyword) => {"
        array << "            const params = { #{display_column_name}_cont: keyword };"
        array << "            const { data } = await this.$request.get('/#{association.class_name.underscore.pluralize}', { params });"
        array << "            return data.map(item => ({ value: item.id, label: item.#{display_column_name} }));"
        array << "          }"
        array << "        }"
        array << "      }"
      end

      array << "    },"
    end

    enum_columns.each do |column|
      next unless column.name.to_sym.in?(resource_detail_entity_attributes)

      array << "    {"
      array << "      prop: '#{column.name}',"
      array << "      label: '#{resource_class.human_attribute_name(column.name)}',"
      array << "      renderCell: (h, { row }) => {"
      array << "        if (!row.#{column.name}) {"
      array << "          return '/'"
      array << "        }"
      array << ""
      array << "        return <el-tag type={TAG_TYPE[row.#{column.name}]}>{ #{resource_class.name.underscore}_#{column.name.pluralize.upcase}[row.#{column.name}] }</el-tag>;"
      array << "      },"

      if render_form_for_attribute?(column.name)
        array << "      form: {"
        array << "        required: true," if required_for_attribute?(column.name)
        array << "        component: 'select',"
        array << "        props: {"
        array << "          options: _.map(#{resource_class.name.underscore}_#{column.name.pluralize.upcase}, (label, value) => ({ label, value }))"
        array << "        }"
        array << "      }"
      end
      array << "    },"
    end

    boolean_columns.each do |column|
      next unless column.name.to_sym.in?(resource_detail_entity_attributes)

      array << "    {"
      array << "      prop: '#{column.name}',"
      array << "      label: '#{resource_class.human_attribute_name(column.name)}',"
      array << "      sort: 'order_by',"
      array << "      renderCell: 'bool',"

      if render_form_for_attribute?(column.name)
        array << "      form: {"
        array << "        required: true," if required_for_attribute?(column.name)
        array << "        component: 'switch',"
        array << "      },"
      end

      array << "    },"
    end

    integer_columns.each do |column|
      next unless column.name.to_sym.in?(resource_detail_entity_attributes)
      next if column.name.to_sym.in?(enum_columns.map(&:name))

      array << "    {"
      array << "      prop: '#{column.name}',"
      array << "      label: '#{resource_class.human_attribute_name(column.name)}',"
      array << "      sort: 'order_by',"

      if render_form_for_attribute?(column.name)
        array << "      form: {"
        array << "        required: true," if required_for_attribute?(column.name)
        array << "        component: 'inputNumber',"
        array << "      },"
      end

      array << "    },"
    end

    decimal_columns.each do |column|
      next unless column.name.to_sym.in?(resource_detail_entity_attributes)

      array << "    {"
      array << "      prop: '#{column.name}',"
      array << "      label: '#{resource_class.human_attribute_name(column.name)}',"
      array << "      sort: 'order_by',"

      if render_form_for_attribute?(column.name)
        array << "      form: {"
        array << "        required: true," if required_for_attribute?(column.name)
        array << "        component: 'inputNumber',"
        array << "      },"
      end

      array << "    },"
    end

    float_columns.each do |column|
      next unless column.name.to_sym.in?(resource_detail_entity_attributes)

      array << "    {"
      array << "      prop: '#{column.name}',"
      array << "      label: '#{resource_class.human_attribute_name(column.name)}',"
      array << "      sort: 'order_by',"

      if render_form_for_attribute?(column.name)
        array << "      form: {"
        array << "        required: true," if required_for_attribute?(column.name)
        array << "        component: 'inputNumber',"
        array << "      },"
      end

      array << "    },"
    end

    date_columns.each do |column|
      next unless column.name.to_sym.in?(resource_detail_entity_attributes)

      array << "    {"
      array << "      prop: '#{column.name}',"
      array << "      label: '#{resource_class.human_attribute_name(column.name)}',"
      array << "      sort: 'order_by',"
      array << "      renderCell: 'time',"
      if render_form_for_attribute?(column.name)
        array << "      form: {"
        array << "        required: true," if required_for_attribute?(column.name)
        array << "        component: 'datePicker',"
        array << "      }"
      end
      array << "    },"
    end

    time_columns.each do |column|
      next unless column.name.to_sym.in?(resource_detail_entity_attributes)

      array << "    {"
      array << "      prop: '#{column.name}',"
      array << "      label: '#{resource_class.human_attribute_name(column.name)}',"
      array << "      sort: 'order_by',"
      array << "      renderCell: 'time',"
      if render_form_for_attribute?(column.name)
        array << "      form: {"
        array << "        required: true," if required_for_attribute?(column.name)
        array << "        component: 'timePicker',"
        array << "      }"
      end
      array << "    },"
    end

    datetime_columns.each do |column|
      next unless column.name.to_sym.in?(resource_detail_entity_attributes)

      array << "    {"
      array << "      prop: '#{column.name}',"
      array << "      label: '#{resource_class.human_attribute_name(column.name)}',"
      array << "      minWidth: 120,"
      array << "      sort: 'order_by',"
      array << "      renderCell: 'time',"
      if render_form_for_attribute?(column.name)
        array << "      form: {"
        array << "        required: true," if required_for_attribute?(column.name)
        array << "        component: 'dateTimePicker',"
        array << "      }"
      end
      array << "    },"
    end

    one_attached_associations.each do |association|
      next unless association.name.to_sym.in?(resource_detail_entity_attributes)

      array << "    {"
      array << "      prop: '#{association.name}',"
      array << "      label: '#{resource_class.human_attribute_name(association.name)}',"
      array << "      width: 120,"
      array << "      renderCell: 'storageAttachment',"
      if render_form_for_attribute?(association.name)
        array << "      form: {"
        array << "        required: true," if required_for_attribute?(association.name)
        array << "        component: 'upload',"
        array << "        props: {"
        array << "          hint: '建议尺寸：TODO'"
        array << "        }"
        array << "      }"
      end
      array << "    },"
    end

    many_attached_associations.each do |association|
      next unless association.name.to_sym.in?(resource_detail_entity_attributes)

      array << "    {"
      array << "      prop: '#{association.name}',"
      array << "      label: '#{resource_class.human_attribute_name(association.name)}',"
      array << "      renderCell: 'storageAttachment',"
      if render_form_for_attribute?(association.name)
        array << "      form: {"
        array << "        required: true," if required_for_attribute?(association.name)
        array << "        component: 'upload',"
        array << "        props: {"
        array << "          limit: 10,"
        array << "          hint: '建议尺寸：TODO'"
        array << "        }"
        array << "      }"
      end
      array << "    },"
    end

    text_columns.each do |column|
      next unless column.name.to_sym.in?(resource_detail_entity_attributes)

      array << "    {"
      array << "      prop: '#{column.name}',"
      array << "      label: '#{resource_class.human_attribute_name(column.name)}',"
      array << "      action: ['hide-in-table'],"
      array << "      renderCell: (h, { row }) => {"
      array << "        if (!row.#{column.name}) {"
      array << "          return '/'"
      array << "        }"
      array << ""
      array << "        return <span style='white-space: pre-wrap; word-break: break-all'>{row.#{column.name}}</span>"
      array << "      },"

      if render_form_for_attribute?(column.name)
        array << "      form: {"
        array << "        required: true," if required_for_attribute?(column.name)
        array << "        component: 'input',"
        array << "        props: {"
        array << "          type: 'textarea',"
        array << "          rows: 10"
        array << "        }"
        array << "      }"
      end
      array << "    },"
    end

    array << <<~CONTENT.strip_heredoc.indent(4)
      {
        prop: 'created_at',
        label: '#{resource_class.human_attribute_name(:created_at)}',
        action: ['hide-in-table'],
        renderCell: 'time',
      },
      {
        prop: 'updated_at',
        label: '#{resource_class.human_attribute_name(:updated_at)}',
        action: ['hide-in-table'],
        renderCell: 'time',
      },
    CONTENT

    array << "    _.merge({"
    array << "      prop: 'action',"
    array << "      label: '操作',"
    array << "      width: 100,"
    array << "      fixed: 'right',"
    if show_api_route
      if opts["belongs_to"]
        array << "      detail: ({ row }) => {"
        array << "        return {"
        array << "          location: { name: '#{collection_name}.show', params: { id: this.$route.params.id, #{resource_name}_id: row.id } }"
        array << "        }"
        array << "      },"
      else
        array << "      detail: true,"
      end
    end
    if update_api_route
      if opts["belongs_to"]
        array << "      edit: ({ row }) => {"
        array << "        return {"
        array << "          location: { name: '#{collection_name}.edit', params: { id: this.$route.params.id, #{resource_name}_id: row.id } }"
        array << "        }"
        array << "      },"
      else
        array << "      edit: true,"
      end
    end
    if destroy_api_route
      array << "      delete: {"
      array << "        handler: async ({ row }) => {"
      array << "          await this.$autoLoading(this.$request.delete(`/#{collection_name}/${row.id}`));"
      array << "          this.$message.success('删除成功');"
      array << "          if (detailPage) {"
      if opts["belongs_to"]
        array << "            this.$router.replace({ name: '#{opts["belongs_to"].pluralize}.#{collection_name}', params: { id: this.$route.params.id } });"
      else
        array << "            this.$router.replace({ name: '#{collection_name}.index', params: { id: this.$route.params.id } });"
      end
      array << "          } else {"
      array << "            this.fetchData();"
      array << "          }"
      array << "        }"
      array << "      }"
    end
    array << "    }, actionColumn)"
    array << "  ]"

    array.join("\n")
  end

  def add_column(data)
    array = []

    array << "    {"
    array << "      prop: '#{data[:prop]}',"
    array << "      label: '#{data[:label]}',"
    array << "      width: #{data[:width]}," if data[:width]
    array << "      sort: 'order_by'," if data[:sort]

    if data[:hide_in_table] || data[:hide_in_detail]
      hide_in_array = []
      hide_in_array << "hide-in-table" if data[:hide_in_table]
      hide_in_array << "hide-in-detail" if data[:hide_in_detail]
      action = hide_in_array.map { |str| "'#{str}'" } .join(", ")

      array << "      action: [#{action}],"
    end

    if data[:render_cell_component]
      if respond_to?("#{data[:render_cell_component]}_render_cell", true)
        render_cell_data_array = send("#{data[:render_cell_component]}_render_cell", data).split("\n")
        start_render_cell_data = render_cell_data_array.shift
        start_render_cell_data = render_cell_data_array.pop

        array << "      renderCell: (h, { row }) => {"
        array += render_cell_data_array.map { |str| " " * 6 + str }
        array << "      },"
      else
        array << "      renderCell: '#{data[:render_cell_component]}',"
      end
    end

    if data[:render_form]
      array << "      form: {"
      array << "        required: true," if data[:required]

      if respond_to?("#{data[:form_component]}_form", true)
        form_data_array = send("#{data[:form_component]}_form", data).split("\n")
        start_form_data = form_data_array.shift
        start_form_data = form_data_array.pop

        array += form_data_array.map { |str| " " * 6 + str }
      else
        array << "        component: '#{data[:form_component]}'"
      end

      array << "      }"
    end

    array << "    },"

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

  def upload_form(data)
    <<~FILE
      {
        component: 'upload',
        props: {
          size: 5,
          limit: #{data[:attribute] == data[:attribute].pluralize ? 9 : 1},
          hint: 'Suggest size: 100x100'
        }
      }
    FILE
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
