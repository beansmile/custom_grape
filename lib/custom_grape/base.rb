module CustomGrape
  module Base
    extend ActiveSupport::Concern

    included do
      helpers CustomGrape::ResourceHelper
    end

    module DSLMethods
      def base_namespace(space = nil, options = {}, &block)
        options.reverse_merge!({
          class_name: space.classify,
          on: :collection
        })

        # 每一个新的namespace都不继承之前namespace或route_param传递的entity
        parent_namespace_options_dup = parent_namespace_options.dup
        parent_namespace_options_dup.delete(:entity)

        # belongs_to需要用到
        parent_namespace_options_dup[:association_chain] ||= []
        parent_namespace_options_dup[:association_chain] << { class_name: options[:class_name] }

        # 继承上级namespace或route_param传递的参数
        options.reverse_merge!(parent_namespace_options_dup)

        namespace(space, options, &block)
      end

      def base_route_param(param, options = {}, &block)
        options[:param] = param
        options.reverse_merge!({
          find_by_key: :id,
          on: :member
        })
        options.reverse_merge!(parent_namespace_options)
        options[:association_chain][-1].merge!(
          param: options[:param],
          find_by_key: options[:find_by_key]
        )

        route_param(param, options, &block)
      end

      def base_route(methods, paths = ["/"], route_options = {}, &block)
        route_options.reverse_merge!(parent_namespace_options)

        if block_given?
          route(methods, paths, route_options, &block)
        else
          method_name = paths

          route(methods, paths, route_options) do
            if resource_params
              run_member_action(method_name, {}, resource_params)
            else
              run_member_action(method_name)
            end
          end
        end
      end

      protected
      def parent_namespace_options
        inheritable_setting.namespace_stackable[:namespace][-1]&.options || {}
      end
    end

    Grape::API::Instance.extend(DSLMethods)
  end
end
