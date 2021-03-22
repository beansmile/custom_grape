# frozen_string_literal: true

namespace :role do
  # 预定义角色部署后自动更新权限
  desc "Sync permissions"
  task sync_permissions: :environment do
    Role.where(kind: [:super, :application, :merchant, :store]).each(&:save)
  end
end
