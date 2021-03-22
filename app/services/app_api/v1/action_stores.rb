# frozen_string_literal: true

class AppAPI::V1::ActionStores < Grape::API
  include Grape::Kaminari

  ACTION_TARGET_TYPES = (::User.defined_actions || []).map { |action| action[:target_type] }.uniq
  ACTION_TYPE_DESC = "行为, #{(::User.defined_actions || []).inject({}) { |hash, action| hash[action[:target_type]] ||= []; hash[action[:target_type]] << action[:action_type]; hash }.map { |target_type, array| "#{target_type}支持#{array.join(",")}" }.join("; ")} "

  namespace :action_stores, desc: "用户行为" do
    helpers do
      def check_action_type
        unless User.defined_actions.any? { |action| action[:target_type] == params[:target_type] && action[:action_type] == params[:action_type] }
          error!("action_type does not have a valid value")
        end
      end

      def resource_class
        @resource_class ||= params[:target_type].classify.constantize
      end

      def resource
        @resource ||= resource_class.find(params[:target_id])
      end

      def end_of_association_chain
        @end_of_association_chain ||= (params[:user_id].present? ? User.find(params[:user_id]) : current_user).send("#{params[:action_type]}_#{params[:target_type].underscore}".pluralize).
          select("#{params[:target_type].underscore.pluralize}.*, actions.id AS actions_id")
      end

      def collection
        return @collection if @collection

        search = end_of_association_chain.accessible_by(current_ability, "read_#{params[:action_type]}".to_sym).ransack(ransack_params)
        search.sorts = "#{params[:order].keys.first} #{params[:order].values.first}" if params[:order].present?

        @collection = search.result(distinct: true).includes(includes).order(default_order)
      end

      def default_order
        "actions_id DESC"
      end
    end

    desc "获取用户行为列表，如点赞文章", {
      detail: <<-NOTES.strip_heredoc
      不同的target_type返回不同的格式
      NOTES
    }
    paginate
    params do
      requires :action_type, type: String, desc: "#{ACTION_TYPE_DESC}"
      requires :target_type, type: String, desc: "对象类型", values: ACTION_TARGET_TYPES
      optional :user_id, type: Integer, desc: "用户ID, 获取自己的不用传"
    end
    get do
      check_action_type

      authorize! "read_#{params[:action_type]}".to_sym, resource_class

      response_collection
    end

    desc "创建用户行为，如点赞文章"
    params do
      requires :action_type, type: String, desc: ACTION_TYPE_DESC
      requires :target_type, type: String, desc: "对象类型", values: ACTION_TARGET_TYPES
      requires :target_id, type: String, desc: "对象id"
    end
    post do
      check_action_type

      authorize! params[:action_type].to_sym, resource

      begin
        User.transaction do
          if current_user.create_action(params[:action_type], target_id: params[:target_id], target_type: params[:target_type])
            # 创建action后的事件
            # after_create_like_post_action
            callback_method = "after_create_#{params[:action_type]}_#{params[:target_type].underscore}_action"
            send(callback_method) if respond_to?(callback_method)

            response_success "操作成功"
          else
            response_error "操作失败"
          end
        end
      # 并发创建同样的数据会报错，捕捉并返回成功
      rescue ActiveRecord::StatementInvalid
        response_success "操作成功"
      end
    end

    desc "销毁用户行为，如取消点赞文章"
    params do
      requires :action_type, type: String, desc: ACTION_TYPE_DESC
      requires :target_type, type: String, desc: "对象类型", values: ACTION_TARGET_TYPES
      requires :target_id, type: String, desc: "对象id"
    end
    delete do
      check_action_type

      if current_user.destroy_action(params[:action_type], target_id: params[:target_id], target_type: params[:target_type])
        response_success "操作成功"
      else
        response_error "操作失败"
      end
    end
  end
end
