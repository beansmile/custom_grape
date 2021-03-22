# frozen_string_literal: true

GrapeSwaggerRails.options.url      = "/api/v1/swagger_doc"
GrapeSwaggerRails.options.app_url  = ""
GrapeSwaggerRails.options.app_name = ENV["APPLICATION"]

GrapeSwaggerRails.options.api_key_name = "Authorization"
GrapeSwaggerRails.options.api_key_type = "header"

GrapeSwaggerRails.options.before_action do
  GrapeSwaggerRails.options.url = "/#{params[:api_type]}/v1/swagger_doc"
end
