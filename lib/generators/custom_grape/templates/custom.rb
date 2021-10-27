module CustomGrape
  module Custom
    module DSLMethods
      def custom_index(route_options = {})
        change_route_setting_description_if_need(description: "#{parent_namespace_options[:class_name].constantize.model_name.human}列表")

        paginate
        custom_route(:get, "/", route_options.reverse_merge({
          is_array: true
        })) do
          authorize! :read, resource_class

          response_collection
        end
      end

      def custom_read_options(route_options = {})
        route_options[:entity] ||= parent_namespace_options[:entity] || "#{entity_namespace}::Simple#{parent_namespace_options[:class_name]}".constantize
        change_route_setting_description_if_need(description: "#{parent_namespace_options[:class_name].constantize.model_name.human}选项列表")

        paginate
        custom_route(:get, "read_options", route_options.reverse_merge({
          is_array: true
        })) do
          authorize! :read_options, resource_class

          @collection = end_of_association_chain.accessible_by(current_ability, :read_options).ransack(ransack_params).result(distinct: true).includes(includes).order(default_order).order("id DESC")

          response_collection
        end
      end

      def custom_create(route_options = {})
        route_options[:entity] ||= parent_namespace_options[:entity] || "#{entity_namespace}::#{parent_namespace_options[:class_name]}Detail".constantize
        change_route_setting_description_if_need(description: "创建#{parent_namespace_options[:class_name].constantize.model_name.human}")

        custom_route(:post, "/", route_options.reverse_merge({
          auth_action: :create
        })) do
          build_resource

          run_member_action(:save)
        end
      end

      def custom_show(route_options = {})
        change_route_setting_description_if_need(description: "#{parent_namespace_options[:class_name].constantize.model_name.human}详情")

        custom_route(:get, "/", route_options) do
          authorize! :read, resource

          response_resource
        end
      end

      def custom_update(route_options = {})
        change_route_setting_description_if_need(description: "更新#{parent_namespace_options[:class_name].constantize.model_name.human}")

        custom_route(:put, "/", route_options) do
          run_member_action(:update, {}, resource_params)
        end
      end

      def custom_destroy(route_options = {})
        change_route_setting_description_if_need(description: "删除#{parent_namespace_options[:class_name].constantize.model_name.human}")

        custom_route(:delete, "/", route_options) do
          run_member_action(:destroy)
        end
      end

      def custom_namespace(space = nil, options = {}, &block)
        options[:class_name] ||= space.classify

        base_namespace(space, options, &block)
      end

      def custom_route_param(param, options = {}, &block)
        base_route_param(param, options, &block)
      end

      def custom_route(methods, paths = ['/'], route_options = {}, &block)
        description = route_setting(:description) || {}

        route_options[:entity] ||= description[:entity] ||
          parent_namespace_options[:entity] ||
          (parent_namespace_options[:on] == :collection ? "#{entity_namespace}::#{parent_namespace_options[:class_name]}" : "#{entity_namespace}::#{parent_namespace_options[:class_name]}Detail").constantize

        if description[:params]
          description[:params].map do |key, value|
            value.reverse_merge!(route_options[:entity].documentation[key.to_sym] || {})
          end
        end

        description[:description] ||= paths
        description[:summary] ||= description[:description]

        route_setting(:description, description)

        base_route(methods, paths, route_options, &block)
      end

      Grape::Http::Headers::SUPPORTED_METHODS.each do |supported_method|
        define_method "custom_#{supported_method.downcase}" do |*args, &block|
          options = args.extract_options!
          paths = args.first || ["/"]
          custom_route(supported_method, paths, options, &block)
        end
      end

      protected
      def entity_namespace
        "#{to_s.split("::")[0]}::Entities"
      end

      def change_route_setting_description_if_need(hash)
        route_setting(:description, (route_setting(:description) || {}).reverse_merge(hash))
      end
    end
  end
end
