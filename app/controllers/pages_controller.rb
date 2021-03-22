# frozen_string_literal: true

class PagesController < ApplicationController
  before_action :set_page

  def show
  end

  private

  def set_page
    application = Bean::Application.find_by!(appid: params[:appid])
    @page ||= application.pages.published.friendly.find params[:id]
    @page.increment!(:views_count)
  end
end
