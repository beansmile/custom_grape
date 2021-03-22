# frozen_string_literal: true
require "test_helper"

class AdminUserTest < ActiveSupport::TestCase
  let(:au) { admin_users(:one) }

  describe "concerns" do
    describe "UserConcern" do
      it "respond to get_access_token" do
        assert_respond_to au, :get_access_token
      end

      it "return token" do
        assert au.get_access_token&.dig(:token)
      end
    end
  end

  describe "associations" do
    it "has_and_belongs_to_many roles" do
      assert_respond_to au, :roles
    end
  end

  describe "validations" do
    it "is valid" do
      assert au.valid?
    end

    it "has email or phone" do
      au.email = nil
      au.phone = nil

      assert_not au.valid?
    end

    it "has password" do
      au.password = nil

      assert_not au.valid?
    end

    it "has minimum length password" do
      au.password = "1234567"

      assert_not au.valid?
    end
  end
end
