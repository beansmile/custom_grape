module CustomGrape
  module ResourceHelper
    mattr_accessor :entity_includes_cache
    @@entity_includes_cache = {}

    def default_order
      @default_order ||= "#{resource_class.table_name}.id DESC"
    end

    def route_options
      @route_options ||= options[:route_options] || {}
    end

    def parent_association_chain
      @parent_association_chain ||= route_options[:association_chain][-2] || {}
    end

    def parent_class
      @parent_class ||= parent_association_chain[:class_name]
    end

    def parent
      @parent ||= parent_class&.find_by!("#{parent_association_chain[:find_by_key]}" => parent_association_chain[:param])
    end

    def resource_class
      @resource_class ||= route_options[:class_name]&.constantize
    end

    def end_of_association_chain
      @end_of_association_chain ||= parent ? parent.send(resource_class.name.tableize) : resource_class
    end

    def collection
      return @collection if @collection

      search = end_of_association_chain.accessible_by(current_ability).ransack(ransack_params)
      search.sorts = "#{params[:order].keys.first} #{params[:order].values.first}" if params[:order].present?

      @collection = search.result(distinct: true).includes(includes).order(default_order).order("#{resource_class.table_name}.id DESC")
    end

    def resource
      @resource ||= end_of_association_chain.includes(includes).find_by!("#{route_options[:find_by_key]}" => params[route_options[:param]])
    end

    def present_collection
      @present_collection ||= params[:page] == 0 ? collection : paginate(collection)
    end

    def response_resource
      present resource, with: route_options[:entity]
    end

    def response_collection
      present present_collection, { with: route_options[:entity] }
    end

    def run_member_action(action, api_options = {}, *data)
      api_options.reverse_merge!({
        auth_action: route_options[:auth_action] || action
      })

      authorize! api_options[:auth_action], resource

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
      @resource_params ||= ActionController::Parameters.new(params).permit(permitted_params)
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
      fetch_entity_includes(route_options[:entity])
    end

    def fetch_entity_includes(entity)
      includes_cache_key = "grape_entity_includes/#{entity.name.underscore.gsub("/", "_")}".to_sym
      includes_cache = @@entity_includes_cache[includes_cache_key]

      return includes_cache if includes_cache

      data = Includes.fetch(entity.name)&.fetch_includes || []
      @@entity_includes_cache[includes_cache_key] = data

      data
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

    def use_cache?
      Rails.env.production? || Rails.env.staging?
    end

    def response_error(message = "error", code = 400)
      error!({code: "#{code}00".to_i, detail: {}, error_message: message }, code)
    end

    def response_record_error(object)
      response_error(object.errors.full_messages.join(","))
    end
  end
end
