# frozen_string_literal: true

namespace :address do
  desc "Covert China address html to json"
  task convert_china_address_html_to_json: :environment do
    # 2019年12月中华人民共和国县以上行政区划代码
    # http://www.mca.gov.cn/article/sj/xzqh/1980/2019/202002281436.html
    china_address_data = Nokogiri::HTML(File.open("./public/2019年12月中华人民共和国县以上行政区划代码.html")).css("tbody tr")[3..-13]

    # 直辖市
    municipality_directly_under_the_central_government_data = {
      "110000": "北京市",
      "120000": "天津市",
      "310000": "上海市",
      "500000": "重庆市"
    }

    # 省直辖县级行政区划
    administrative_divisions_at_county_level_directly_under_the_jurisdiction_of_a_province = [
      "419001", # 济源市
      "429004", # 仙桃市
      "429005", # 潜江市
      "429006", # 天门市
      "429021", # 神农架林区
      "469001", # 五指山市
      "469002", # 琼海市
      "469005", # 文昌市
      "469006", # 万宁市
      "469007", # 东方市
      "469021", # 定安县
      "469022", # 屯昌县
      "469023", # 澄迈县
      "469024", # 临高县
      "469025", # 白沙黎族自治县
      "469026", # 昌江黎族自治县
      "469027", # 乐东黎族自治县
      "469028", # 陵水黎族自治县
      "469029", # 保亭黎族苗族自治县
      "469030", # 琼中黎族苗族自治县
      "659001", # 石河子市
      "659002", # 阿拉尔市
      "659003", # 图木舒克市
      "659004", # 五家渠市
      "659005", # 北屯市
      "659006", # 铁门关市
      "659007", # 双河市
      "659008", # 可克达拉市
      "659009", # 昆玉市
      "659010", # 胡杨河市
    ]

    json = {}

    # 省，由于台湾、香港、澳门暂无城市数据，暂不处理
    china_address_data.each do |tr_element|
      td_elements = tr_element.css("td")

      code = td_elements[1].text

      next unless code[2..-1] == "0000"

      name = td_elements[2].children[-1].text.strip

      name = municipality_directly_under_the_central_government_data[code.to_sym] || name

      json[code] = {
        "name" => name,
        "children" => {}
      }
    end

    # 直辖市
    municipality_directly_under_the_central_government_data.each do |data|
      json[data[0].to_s]["children"][data[0].to_s] = { "name" => "#{data[1]}", "children" => {} }
    end

    # 直辖县级行政区划
    administrative_divisions_at_county_level_directly_under_the_jurisdiction_of_a_province.each do |code|
      json["#{code[0..1]}0000"]["children"]["#{code[0..3]}00"] = { "name" => "省直辖县级行政区划", "children" => {} }
    end

    china_address_data.each do |tr_element|
      td_elements = tr_element.css("td")

      code = td_elements[1].text

      next if code[2..-1] == "0000"
      next unless code[4..-1] == "00"

      name = td_elements[2].children[-1].text.strip

      json["#{code[0..1]}0000"]["children"][code] = { "name" => name, "children" => {} }
    end

    # 区
    china_address_data.each do |tr_element|
      td_elements = tr_element.css("td")

      code = td_elements[1].text

      next if code[4..-1] == "00"

      name = td_elements[2].children[-1].text.strip

      # 直辖市的city code比较特殊，以0000结尾
      city_code = municipality_directly_under_the_central_government_data.detect { |data| data[0][0..1] == code[0..1] }.try(:[], 0).try(:to_s) || "#{code[0..3]}00"

      json["#{code[0..1]}0000"]["children"][city_code]["children"][code] = { "name" => name, "children" => {} }
    end

    File.open("public/2019年12月中华人民共和国县以上行政区划数据.json", "w") do |f|
      f.write(json.to_json)
    end
  end
end
