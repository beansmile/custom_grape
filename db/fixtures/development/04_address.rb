# frozen_string_literal: true

country = Bean::Country.first
province = country.provinces.first
city = province.cities.first
district = city.districts.first

Bean::Address.seed(
  :id,
  { id: 1, country_id: country.id, province_id: province.id, city_id: city.id, district_id: district.id, detail_info: "街道A", postal_code: "528400", receiver_name: "收货人A", tel_number: "13800138000", is_default: true, user_id: 1 }
)
