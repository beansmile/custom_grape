# frozen_string_literal: true

class AdminUserMailer < ApplicationMailer
  def invite
    @admin_users_role = params[:admin_users_role]
    mail(to: @admin_users_role.admin_user.email, subject: "您有新的邀请")
  end
end
