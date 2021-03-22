# frozen_string_literal: true

# 由于该任务执行时间比较长，所以如果有数据则不再重复执行，如需要重新生成数据请注释unless条件
unless Bean::Country.any?
  Bean::Country.seed_once(:code) do |c|
    c.name = "中国大陆"
    c.code = "156"
  end

  china = Bean::Country.find_by(code: "156")

  JSON.parse(File.read("public/2019年12月中华人民共和国县以上行政区划数据.json")).each do |province_code, province_data|
    Bean::Province.seed_once(:code, :country_id) do |p|
      p.name = province_data["name"]
      p.code = province_code
      p.country_id = china.id
    end

    province_id = Bean::Province.find_by(code: province_code).id

    province_data["children"].each do |city_code, city_data|
      Bean::City.seed_once(:code, :province_id) do |c|
        c.name = city_data["name"]
        c.code = city_code
        c.province_id = province_id
      end

      city_id = Bean::City.find_by(code: city_code).id

      city_data["children"].each do |district_code, district_data|
        Bean::District.seed_once(:code, :city_id) do |d|
          d.name = district_data["name"]
          d.code = district_code
          d.city_id = city_id
        end
      end
    end
  end
end
