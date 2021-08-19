module CustomGrape
  module ResourceHelper
    mattr_accessor :entity_includes_cache
    @@entity_includes_cache = {}

    def default_order
      @default_order ||= "id desc"
    end

    def end_of_association_chain
      @end_of_association_chain ||= resource_class
    end

    def collection
      return @collection if @collection

      search = end_of_association_chain.accessible_by(current_ability).ransack(ransack_params)
      search.sorts = "#{params[:order].keys.first} #{params[:order].values.first}" if params[:order].present?

      @collection = search.result(distinct: true).includes(includes).order(default_order).order("id DESC")
    end

    def resource
      @resource ||= resource_class.includes(resource_includes).find_by!("#{find_by_key}" => params[find_by_key])
    end

    def find_by_key
      @find_by_key ||= :id
    end

    def authorize_and_response_collection
      authorize! :read, auth_resource_class

      response_collection
    end

    def authorize_and_response_read_options
      authorize! :read_options, auth_resource_class

      @collection = end_of_association_chain.accessible_by(current_ability, :read_options).ransack(ransack_params).result(distinct: true).order(default_order).order("id DESC")

      options = { with: route_setting_entity }

      present present_collection, options
    end

    def present_collection
      @present_collection ||= params[:page] == 0 ? collection : paginate(collection)
    end

    def collection_present_additional_options
      method_name = "#{collection_entity.name.split("::").last.underscore}_present_additional_options"

      respond_to?(method_name) ? send(method_name) : {}
    end

    def response_collection
      options = { with: collection_entity }
      options["#{resource_class.name.underscore}_ids".to_sym] = present_collection.map(&:id)
      options.reverse_merge!(collection_present_additional_options)

      present present_collection, options
    end

    def authorize_and_response_resource
      authorize! :read, auth_resource

      response_resource
    end

    def response_resource
      present resource, with: resource_entity
    end

    def authorize_and_create_resource(options = {})
      options.reverse_merge!({
        authorize: true
      })

      create_resource(options)
    end

    def create_resource(options = {})
      options.reverse_merge!({
        auth_action: :create
      })

      build_resource
      run_member_action(:save, options)
    end

    def authorize_and_update_resource(options = {})
      authorize_and_run_member_action(:update, options, resource_params)
    end

    def update_resource(options = {})
      run_member_action(:update, options, resource_params)
    end

    def authorize_and_destroy_resource(options = {})
      authorize! :destroy, resource

      if resource.destroy
        response_success
      else
        response_record_error(resource)
      end
    end

    def authorize_and_run_member_action(action, options = {}, *data)
      options.reverse_merge!({
        authorize: true
      })

      run_member_action(action, options, *data)
    end

    def run_member_action(action, options = {}, *data)
      options.reverse_merge!({
        authorize: false,
        auth_action: action,
      })

      if options[:authorize]
        authorize! options[:auth_action], auth_resource
      end

      if data.present? ? resource.send(action, *data) : resource.send(action)
        response_resource
      else
        response_record_error(resource)
      end
    end

    def current_ability
      @current_ability ||= ::Ability.new(ability_user)
    end
    delegate :can?, :cannot?, :authorize!, to: :current_ability

    def ability_user
      current_user
    end

    def resource_params
      ActionController::Parameters.new(params).permit(permitted_params)
    end

    def route_setting_entity
      @route_setting_entity ||= route.settings[:description][:entity] || route.settings[:description][:success]
    end

    def collection_entity
      @collection_entity ||= route_setting_entity || "#{entity_namespace_name}::#{resource_class}".constantize
    end

    def resource_entity
      @resource_entity ||= if route_setting_entity
                             route_setting_entity
                           else
                             begin
                               "#{entity_namespace_name}::#{resource_class}Detail".constantize
                             rescue NameError => e
                               "#{entity_namespace_name}::#{resource_class}".constantize
                             end
                           end
    end

    def entity_namespace_name
      raise "请重写entity_namespace_name方法"
    end

    def resource_class
      # request.env["REQUEST_PATH"] 返回类似/app_api/v1/products的字符串
      @resource_class ||= (request.env["REQUEST_PATH"] || request.path).split("/")[3].classify.constantize
    end

    def permitted_params
      # clone一份数据，避免 conver 后改变原来的值出现下面error
      # TypeError (no implicit conversion from nil to integer)
      # 原因：conver后从 [:title, :images] 变成 [:title, {:images=>[]}]
      # 导致 data.index("images") 为nil
      declared_params = route.settings[:declared_params].deep_dup

      description_params = route.settings[:description][:params] || {}

      description_params.select do |key, value|
        if value[:type].blank? || value[:type] == "[JSON]"
          false
        elsif value[:type].match(/\[/)
          true
          # key可能包含特殊字符，例如方括号："shipping_categories[shipping_methods][calculator]"，此时需用Regexp.escape方法
        elsif value[:type] == "JSON" && !description_params.any? { |k, _| k.match?(/^#{Regexp.escape(key)}\[/) }
          true
        elsif value[:type] == "File"
          true
        else
          false
        end
      end.each do |key, value|
        key_array = key.gsub("[", " ").gsub("]", " ").split(" ")

        declared_params = conver_declared_params(declared_params, key_array, value)
      end

      declared_params
    end

    def conver_declared_params(data, key_array, value)
      key = key_array.shift.to_sym

      if key_array == []
        data[data.index(key)] = if value[:type] == "JSON" || value[:type] == "File"
                                  { key => {} }
                                else
                                  { key => [] }
                                end
      else
        key_array.each do |k|
          index = data.index { |value| value.is_a?(Hash) && value[key] }

          convered_data = conver_declared_params(data[index][key], key_array, value)

          data[index][key] = convered_data if key_array == []
        end
      end

      data
    end

    # 如果要处理 n + 1 问题，需重写该方法
    def includes
      fetch_entity_includes(collection_entity, resource_class)
    end

    def resource_includes
      fetch_entity_includes(resource_entity, resource_class)
    end

    def build_resource
      @resource = end_of_association_chain.new(resource_params)
    end

    def ransack_params
      documentation_filter_params = (route.settings[:declared_params] - [:page, :per_page, :offset, :order]).map(&:to_s)

      params.select { |key, _| key.in?(documentation_filter_params) && key.in?(ransack_keys) }.map { |key, value| [key, value.is_a?(String) ? value.strip : value] }.to_h
    end

    # 根据Ransack.predicates.keys来猜测哪些参数是查询参数
    def ransack_keys
      predicates_strings = Ransack.predicates.keys.map { |key| "_#{key}$" }.join("|")
      # 生成后的内容 /(_eq$|_eq_any$|_eq_all$|_not_eq$|_not_eq_any$|_not_eq_all$|_matches$|_matches_any$|_matches_all$|_does_not_match$|_does_not_match_any$|_does_not_match_all$|_lt$|_lt_any$|_lt_all$|_lteq$|_lteq_any$|_lteq_all$|_gt$|_gt_any$|_gt_all$|_gteq$|_gteq_any$|_gteq_all$|_in$|_in_any$|_in_all$|_not_in$|_not_in_any$|_not_in_all$|_cont$|_cont_any$|_cont_all$|_not_cont$|_not_cont_any$|_not_cont_all$|_start$|_start_any$|_start_all$|_not_start$|_not_start_any$|_not_start_all$|_end$|_end_any$|_end_all$|_not_end$|_not_end_any$|_not_end_all$|_true$|_not_true$|_false$|_not_false$|_present$|_blank$|_null$|_not_null$|_contains$|_contains_any$|_contains_all$|_starts_with$|_starts_with_any$|_starts_with_all$|_ends_with$|_ends_with_any$|_ends_with_all$|_equals$|_equals_any$|_equals_all$|_greater_than$|_greater_than_any$|_greater_than_all$|_less_than$|_less_than_any$|_less_than_all$|_gteq_datetime$|_gteq_datetime_any$|_gteq_datetime_all$|_lteq_datetime$|_lteq_datetime_any$|_lteq_datetime_all$)/
      regular_match = /(#{predicates_strings})/

      params_ransack_keys = []

      params.each do |key, _|
        if key.match?(regular_match)
          params_ransack_keys << key
        end
      end
      (params_ransack_keys + resource_class.ransackable_scopes(ability_user)).uniq - except_ransack_keys
    end

    # 如果有参数符合ransack_key匹配规则但又不希望被当做ransack_key处理，可以重写该方法
    def except_ransack_keys
      []
    end

    def guess_includes(entity, model)
      entity.root_exposures.inject([]) do |array, exposure|
        if exposure.respond_to?(:using_class)
          if exposure.using_class == Entities::ActiveStorageAttached
            if attachment = model.reflect_on_all_attachments.detect { |attachment| attachment.name == exposure.attribute }
              if attachment.is_a?(ActiveStorage::Reflection::HasOneAttachedReflection)
                array << { "#{attachment.name}_attachment".to_sym => [:blob] }
              else
                array << { "#{attachment.name}_attachments".to_sym => [:blob] }
              end
            end
          elsif association = model.reflect_on_all_associations.detect { |association| association.name == exposure.attribute }
            array << { association.name => fetch_entity_includes(exposure.using_class, association.klass) }
          end
          # 处理ActsAsTaggableOn N + 1
        elsif defined?(ActsAsTaggableOn) && resource_class.respond_to?(:tag_types) && exposure.attribute.to_s.match(/_list$/)
          column_name = exposure.key.to_s.split("_")[0..-2].join("_").pluralize.to_sym

          array << column_name if resource_class.tag_types.include?(column_name)
        end

        array
      end
    end

    def additional_includes(entity)
      # simple_user_additional_includes
      # user_additional_includes
      # user_detail_additional_includes
      method = "#{entity.name.split("::")[2..-1].join("_").underscore}_additional_includes"

      respond_to?(method) ? send(method) : []
    end

    def except_includes(entity)
      # simple_user_except_includes
      # user_except_includes
      # user_detail_except_includes
      method = "#{entity.name.split("::")[2..-1].join("_").underscore}_except_includes"

      respond_to?(method) ? send(method) : []
    end

    def fetch_entity_includes(entity, model)
      # app_api_entities_user_includes
      # app_api_entities_user_detail_includes
      # app_api_entities_simple_user_includes
      includes_cache_key = "#{entity.name.underscore.gsub("/", "_")}_includes".to_sym
      includes_cache = @@entity_includes_cache[includes_cache_key]

      return includes_cache if use_cache? && includes_cache.present?

      # user_includes
      # user_detail_includes
      # simple_user_includes
      includes_method = "#{entity.name.split("::").last.underscore}_includes"

      data = if respond_to?(includes_method)
               send(includes_method)
             else
               guess_includes(entity, model) - except_includes(entity) + additional_includes(entity)
             end

      @@entity_includes_cache[includes_cache_key] = data

      data
    end

    def use_cache?
      Rails.env.production? || Rails.env.staging?
    end

    def auth_resource
      @auth_resource ||= resource
    end

    def auth_resource_class
      @auth_resource_class ||= resource_class
    end

    def response_success(message = "OK", options = {})
      { code: 200, message: message }.merge(options)
    end

    def response_error(message = "error", code = 400)
      error!({code: "#{code}00".to_i, detail: {}, error_message: message }, code)
    end

    def response_record_error(object)
      response_error(object.errors.full_messages.join(","))
    end
  end
end
