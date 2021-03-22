# frozen_string_literal: true

class AppAPI::V1::Bean::Countries < API
  include Grape::Kaminari

  apis :index, {
    find_by_key: :code
  } do
    helpers do
      params :index_params do
        optional :code_cont, @api.resource_entity.documentation[:code]
        optional :name_cont, @api.resource_entity.documentation[:name]
      end
    end # helpers

    route_param :code do
      namespace :regions do
        desc "国家地址数据", {
          summary: "国家地址数据"
        }
        get do
          redis_regions = Redis::List.new("#{resource.code}-regions", marshal: true)

          if redis_regions.empty?
            resource.provinces.includes(cities: :districts).find_each do |province|
              redis_regions << {
                id: province.id,
                name: province.name,
                code: province.code,
                cities: province.cities.map do |city|
                  {
                    id: city.id,
                    name: city.name,
                    code: city.code,
                    districts: city.districts.map do |district|
                      {
                        id: district.id,
                        name: district.name,
                        code: district.code
                      }
                    end
                  }
                end
              }
            end
          end

          present redis_regions.values
        end
      end
    end
  end # apis
end
