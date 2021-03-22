# frozen_string_literal: true

require "test_helper"
require "generators/admin_view_template/admin_view_template_generator"

class AdminViewTemplateGeneratorTest < Rails::Generators::TestCase
  tests AdminViewTemplateGenerator
  destination Rails.root.join("tmp/generators")
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end
