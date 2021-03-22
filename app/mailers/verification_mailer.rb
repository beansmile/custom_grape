# frozen_string_literal: true

class VerificationMailer < ApplicationMailer
  def send_code
    @target = params[:target]
    @title = params[:title]
    @code = params[:code]

    mail(to: @target, subject: @title)
  end
end
