# frozen_string_literal: true

module Entities
  class Model < CustomGrape::Entity
    expose :id, documentation: { type: Integer, desc: "ID" }
    expose :created_at, documentation: { type: DateTime, desc: "创建时间" }
    expose :updated_at, documentation: { type: DateTime, desc: "更新时间" }
    expose :cn do |obj|
      obj.class.name
    end
    expose :tn do |obj|
      obj.class.table_name
    end

    # 用于 app_api
    def current_user
      return @current_user if @current_user

      @current_user = options[:current_user] if options[:current_user]
      @current_user = options[:env]["api.endpoint"]&.current_user if options[:env]

      @current_user
    end

    # 用于 admin_api
    def current_role
      return @current_role if @current_role

      @current_role = options[:current_role] if options[:current_role]
      @current_role = options[:env]["api.endpoint"]&.current_role if options[:env]

      @current_role
    end

    def resource_name
      object.class.name.underscore
    end

    def collection_name
      resource_name.pluralize
    end
  end
end
