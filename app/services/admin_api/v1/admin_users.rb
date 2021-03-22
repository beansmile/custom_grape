# frozen_string_literal: true
class AdminAPI::V1::AdminUsers < API
  namespace :admin_users do
    desc "获取当前管理员的目标页面权限", detail: <<-NOTES.strip_heredoc
    ```json
    {
      "abilities": {
        "admin_users": [
          "read",
          "create",
          "update",
          "destroy"
        ]
      }
    }
    ```
    NOTES
    get "abilities" do
      if current_role
        abilities = current_role.computed_permissions.to_a.reduce({}) do |memo, rc|
          memo[rc.namespace.map(&:to_s).join.pluralize] ||= []
          memo[rc.namespace.map(&:to_s).join.pluralize].push(rc.name)
          memo
        end

        { abilities: abilities }
      else
        { abilities: {} }
      end
    end
  end
end
