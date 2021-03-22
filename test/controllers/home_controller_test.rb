# frozen_string_literal: true

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  describe "#index" do
    it "succeed" do
      get "/"

      assert_response :success
    end
  end
end
