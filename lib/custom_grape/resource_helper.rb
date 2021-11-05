module CustomGrape
  module ResourceHelper
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

      search = end_of_association_chain.accessible_by(current_ability).ransack(declared(params), auth_object: ability_user)
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
      present present_collection, with: route_options[:entity]
    end

    def run_member_action(action, api_options = {}, *data)
      api_options.reverse_merge!({
        auth_action: route_options[:auth_action] || action
      })

      authorize! api_options[:auth_action], resource

      if data.present? ? resource.send(action, *data) : resource.send(action)
        response_resource
      else
        response_error(resource.errors.full_messages.join(","))
      end
    end

    def current_ability
      @current_ability ||= ::Ability.new(ability_user)
    end
    delegate :can?, :cannot?, :authorize!, to: :current_ability

    def ability_user
      @ability_user ||= current_user
    end

    def includes
      @includes ||= route_options[:entity].respond_to?(:includes) ? route_options[:entity].includes(cache: includes_use_cache?) : []
    end

    def build_resource
      @resource = end_of_association_chain.new(declared(params))
    end

    def response_error(message)
      error!(message)
    end

    def includes_use_cache?
      Rails.env.production? || Rails.env.staging?
    end
  end
end
