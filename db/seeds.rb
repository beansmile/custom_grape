# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

unless AdminUser.exists?
  puts "Create AdminUser"

  Role.create!(name: "超级管理员", kind: "super")
  # Role.create!(name: "应用管理员", kind: "application")
  # Role.create!(name: "商家管理员", kind: "merchant")
  Role.create!(name: "店铺管理员", kind: "store")

  AdminUser.create!(email: "admin@example.com", password: "password", name: "admin", role_ids: [Role.first.id])
end
