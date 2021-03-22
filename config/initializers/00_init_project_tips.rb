# frozen_string_literal: true

if Rails.application.class.parent.name == "Backend" && Rails.root.to_s.split("/").last != "common-wineries-backend"
  begin
    raise "请把config/application.rb的Backend module name修改为当前项目的name（如#{Rails.root.to_s.split("/").last.gsub("-", "_").classify}）"
  rescue RuntimeError => error
    puts "###################################################################"
    puts error.message
    puts "###################################################################"

    exit
  end
end
