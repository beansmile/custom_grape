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
        split_resource_class_name = options[:resource_class].name.split("::")
        simple_entity_name ||= if split_resource_class_name.length > 1
                                 (split_resource_class_name[0..-2] + ["Simple#{split_resource_class_name[-1]}"]).join("::")
                               else
                                 "Simple#{options[:resource_class]}"
                               end

        options[:read_options_entity] ||= "#{entity_namespace}::#{simple_entity_name}".constantize rescue nil
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
        # 支持 apis [:index, show: {}, create: {}], {}
        hash_actions = actions.extract_options!
        unless hash_actions.empty?
          hash_actions.each do |key, value|
            actions.push({ key => value })
          end
        end

        apis_config[object_id] ||= { class_name: base.name }
        apis_find_by_key = apis_config[object_id][:find_by_key] = options.delete(:find_by_key)
        apis_collection_entity = apis_config[object_id][:collection_entity] = options[:collection_entity]
        apis_read_options_entity = apis_config[object_id][:read_options_entity] = options[:read_options_entity]
        apis_resource_entity = apis_config[object_id][:resource_entity] = options[:resource_entity]
        apis_resource_class = apis_config[object_id][:resource_class] = options[:resource_class]
        apis_belongs_to = options.delete(:belongs_to)
        apis_belongs_to_find_by_key = options.delete(:belongs_to_find_by_key)
        apis_namespace = options.delete(:namespace)

        config_key = ""
        config_key = "/#{apis_namespace}" if apis_namespace
        if apis_belongs_to
          config_key += "/#{apis_belongs_to.to_s.pluralize.downcase}"
          config_key += if apis_belongs_to_find_by_key
                          "/:#{apis_belongs_to_find_by_key}"
                        else
                          "/:#{apis_belongs_to.to_s.foreign_key}"
                        end
        end
        config_key += "/#{base.name.split("::")[2..-1].join("::").underscore.pluralize}"

        namespace config_key do
          helpers do
            params :index_params do; end
            params :read_options_params do; end
            params :create_params do; end
            params :update_params do; end

            define_method :resource_class do
              @resource_class ||= apis_resource_class
            end

            define_method :parent do
              return @parent if @parent
              return unless apis_belongs_to

              @parent = if apis_belongs_to_find_by_key
                          parent_class.find_by!(apis_belongs_to_find_by_key => params[apis_belongs_to_find_by_key.to_sym])
                        else
                          parent_class.find(params[apis_belongs_to.to_s.foreign_key.to_sym])
                        end
            end

            define_method :parent_class do
              return @parent_class if @parent_class
              return unless apis_belongs_to

              @parent_class = resource_class.reflect_on_association(apis_belongs_to).class_name.classify.constantize
            end

            define_method :end_of_association_chain do
              @end_of_association_chain ||= parent ? parent.send(resource_class.name.tableize) : resource_class
            end

            define_method :collection_entity do
              @collection_entity ||= apis_collection_entity
            end

            define_method :read_options_entity do
              @read_options_entity ||= apis_read_options_entity
            end

            define_method :resource_entity do
              @resource_entity ||= apis_resource_entity
            end

            define_method :find_by_key do
              @find_by_key ||= apis_find_by_key
            end

            def index_api; authorize_and_response_collection; end
            def read_options_api; authorize_and_response_read_options; end
            def show_api; authorize_and_response_resource; end
            def create_api; authorize_and_create_resource; end
            def update_api; authorize_and_update_resource; end
            def destroy_api; authorize_and_destroy_resource; end
          end

          instance_exec(&block) if block_given?

          show_api_index = nil

          actions_dup = actions.dup

          actions.each_with_index do |action, index|
            action_name = action.is_a?(Hash) ? action.keys[0] : action

            show_api_index = index if action_name.to_s == "show"

            break
          end

          # 把show_api移到最后
          if show_api_index
            actions_dup.delete_at(show_api_index)
            actions_dup << actions[show_api_index]
          end

          actions_dup.each do |action|
            if action.is_a?(Hash)
              action_name = action.keys[0]
              api_options = action.values[0]
            else
              action_name = action
              api_options = {}
            end

            api_options[:tags] = (api_options[:tags] || []) + ["Model #{resource_class.model_name.human}: #{resource_class.name.underscore.pluralize}"]

            send("#{action_name}_api", api_options.reverse_merge(options))
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
            success: resource_entity
          }.merge(options)
          params do
            use "#{path}_params".to_sym if (@api.namespace_stackable_with_hash(:named_params) || {})["#{path}_params".to_sym]
          end
          route method, path do
            authorize_and_run_member_action(action, { auth_action: auth_action }, resource_params)
          end
        end
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

      def read_options_entity
        apis_config[object_id][:read_options_entity]
      end

      def resource_entity
        apis_config[object_id][:resource_entity]
      end

      def index_api(options = {})
        desc "#{resource_class.model_name.human}列表", {
          summary: "#{resource_class.model_name.human}列表",
          success: collection_entity,
          is_array: true
        }.merge(options)
        paginate
        params do; use :index_params; end
        get do; index_api; end
      end

      def read_options_api(options = {})
        desc "#{resource_class.model_name.human}选项列表", {
          summary: "#{resource_class.model_name.human}选项列表",
          success: read_options_entity,
          is_array: true
        }.merge(options)
        paginate
        params do; use :read_options_params; end
        get "read_options" do; read_options_api; end
      end

      def show_api(options = {})
        route_param find_by_key do
          desc "#{resource_class.model_name.human}详情", {
            summary: "#{resource_class.model_name.human}详情",
            success: resource_entity
          }.merge(options)
          get do; show_api; end
        end
      end

      def create_api(options = {})
        desc "创建#{resource_class.model_name.human}", {
          summary: "创建#{resource_class.model_name.human}",
          success: resource_entity
        }.merge(options)
        params do; use :create_params; end
        post do; create_api; end
      end

      def update_api(options = {})
        route_param find_by_key do
          desc "更新#{resource_class.model_name.human}", {
            summary: "更新#{resource_class.model_name.human}",
            success: resource_entity
          }.merge(options)
          params do; use :update_params; end
          put do; update_api; end
        end
      end

      def destroy_api(options = {})
        route_param find_by_key do
          desc "删除#{resource_class.model_name.human}", {
            summary: "删除#{resource_class.model_name.human}",
            success: CustomGrape::Entities::SuccessfulResult
          }.merge(options)
          delete do; destroy_api; end
        end
      end
    end

    Grape::API::Instance.extend(DSLMethods)
  end
end
