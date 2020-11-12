module CustomGrape
  module Action
    extend ActiveSupport::Concern

    included do
      helpers CustomGrape::ResourceHelper
    end

    module DSLMethods
      # 如apis猜测的resource_class或collection_entity不满足实际情况，则可自定义更多的方法
      # def custom_apis(*args, &block)
      #   options = args.extract_options!
      #   actions = args.flatten
      #
      #   这里重写符合实际情况的代码
      #
      #   apis(*args, options, &block)
      # end
      #
      # # 用法
      # apis :index, :show, :create, :update, :destroy  do
      #   xxx
      # end
      #
      # apis :index, :show, :create, :update, :destroy, namespace: :mine  do
      #   xxx
      # end
      #
      # apis :index, :show, :create, :update, :destroy, belongs_to: :category do
      #   xxx
      # end
      def apis(*args, &block)
        options = args.extract_options!
        actions = args.flatten

        entity_namespace = "::#{base.name.split("::")[0]}::Entities"
        options[:find_by_key] ||= :id
        options[:resource_class] ||= base.name.split("::")[2..-1].join("::").singularize.constantize
        options[:collection_entity] ||= "#{entity_namespace}::#{options[:resource_class]}".constantize
        options[:resource_entity] ||= begin
                                        "#{entity_namespace}::#{options[:resource_class]}Detail".constantize
                                      rescue NameError
                                        "#{entity_namespace}::#{options[:resource_class]}".constantize
                                      end

        base_apis(*actions, options, &block)
      end

      def base_apis(*args, &block)
        options = args.extract_options!
        actions = args.flatten

        apis_config[object_id] ||= {}
        apis_find_by_key = apis_config[object_id][:find_by_key] = options.delete(:find_by_key)
        apis_collection_entity = apis_config[object_id][:collection_entity] = options[:collection_entity]
        apis_resource_entity = apis_config[object_id][:resource_entity] = options[:resource_entity]
        apis_resource_class = apis_config[object_id][:resource_class] = options[:resource_class]
        apis_belongs_to = options.delete(:belongs_to)
        apis_namespace = options.delete(:namespace)

        config_key = ""
        config_key = "/#{apis_namespace}" if apis_namespace
        config_key += "/#{apis_belongs_to.to_s.pluralize.downcase}/:#{apis_belongs_to.to_s.foreign_key}" if apis_belongs_to
        config_key += "/#{base.name.split("::")[2..-1].join("::").underscore.pluralize}"

        namespace config_key do
          helpers do
            params :index_params do; end
            params :create_params do; end
            params :update_params do; end

            define_method :resource_class do
              @resource_class ||= apis_resource_class
            end

            define_method :parent do
              return @parent if @parent
              return unless apis_belongs_to

              @parent = apis_belongs_to.to_s.classify.constantize.find(params[apis_belongs_to.to_s.foreign_key.to_sym])
            end

            define_method :end_of_association_chain do
              @end_of_association_chain ||= parent ? parent.send(resource_class.name.tableize) : resource_class
            end

            define_method :collection_entity do
              @collection_entity ||= apis_collection_entity
            end

            define_method :resource_entity do
              @resource_entity ||= apis_resource_entity
            end

            define_method :find_by_key do
              @find_by_key ||= apis_find_by_key
            end

            def index_api; authorize_and_response_collection; end
            def show_api; authorize_and_response_resource; end
            def create_api; authorize_and_create_resource; end
            def update_api; authorize_and_update_resource; end
            def destroy_api; authorize_and_destroy_resource; end
          end

          instance_exec(&block) if block_given?

          actions.each do |action|
            send("#{action}_api", options)
          end
        end
      end

      def member_api(path, options = {})
        summary = options.delete(:summary) || path
        auth_action = options.delete(:auth_action) || path
        action = options.delete(:action) || path
        method = options.delete(:method) || :get

        route_param find_by_key do
          desc summary, {
            summary: summary,
            success: resource_entity,
            skip_authentication: ability.can?(auth_action, resource_class)
          }.merge(options)
          params do
            use "#{path}_params".to_sym if (@api.namespace_stackable_with_hash(:named_params) || {})["#{path}_params".to_sym]
          end
          route method, path do
            authorize_and_run_member_action(action, { auth_action: auth_action }, resource_params)
          end
        end
      end

      def ability
        ability = Ability.new
      end

      def apis_config
        @@apis_config ||= {}
      end

      def find_by_key
        apis_config[object_id][:find_by_key]
      end

      def resource_class
        apis_config[object_id][:resource_class]
      end

      def collection_entity
        apis_config[object_id][:collection_entity]
      end

      def resource_entity
        apis_config[object_id][:resource_entity]
      end

      def index_api(options = {})
        desc "#{resource_class.model_name.human}列表", {
          summary: "#{resource_class.model_name.human}列表",
          success: collection_entity,
          is_array: true,
          skip_authentication: ability.can?(:read, resource_class)
        }.merge(options)
        paginate
        params do; use :index_params; end
        get do; index_api; end
      end

      def show_api(options = {})
        route_param find_by_key do
          desc "#{resource_class.model_name.human}详情", {
            summary: "#{resource_class.model_name.human}详情",
            success: resource_entity,
            skip_authentication: ability.can?(:read, resource_class)
          }.merge(options)
          get do; show_api; end
        end
      end

      def create_api(options = {})
        desc "创建#{resource_class.model_name.human}", {
          summary: "创建#{resource_class.model_name.human}",
          success: resource_entity,
          skip_authentication: ability.can?(:create, resource_class)
        }.merge(options)
        params do; use :create_params; end
        post do; create_api; end
      end

      def update_api(options = {})
        route_param find_by_key do
          desc "更新#{resource_class.model_name.human}", {
            summary: "更新#{resource_class.model_name.human}",
            success: resource_entity,
            skip_authentication: ability.can?(:update, resource_class)
          }.merge(options)
          params do; use :update_params; end
          put do; update_api; end
        end
      end

      def destroy_api(options = {})
        route_param find_by_key do
          desc "删除#{resource_class.model_name.human}", {
            summary: "删除#{resource_class.model_name.human}",
            success: resource_entity,
            skip_authentication: ability.can?(:destroy, resource_class)
          }.merge(options)
          delete do; destroy_api; end
        end
      end
    end

    Grape::API::Instance.extend(DSLMethods)
  end
end