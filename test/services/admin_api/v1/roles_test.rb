# frozen_string_literal: true
require "test_helper"

class ::AdminAPI::V1::RolesTest < ActionDispatch::IntegrationTest
  describe "GET /admin_api/v1/roles" do
    it "succeed" do
      auth_get "/admin_api/v1/roles", headers: { "Current-Role-Id" => 2 }

      assert_response :success
      assert_not_empty json_resp
    end
  end

  describe "POST /admin_api/v1/roles" do
    [
      {
        name: "role",
        store_id: 1
      },
      {
        name: "role",
        store_id: 1,
        permissions_attributes: {
          role: {
            read: true
          }
        }
      }
    ].each do |params|
      it "succeed" do
        auth_post(
          "/admin_api/v1/roles",
          params: params,
          headers: { "Current-Role-Id" => 2 } # 只有店铺管理员可以创建角色
        )

        assert_response :success
      end
    end

    [
      {},
      {
        name: ""
      }
    ].each do |params|
      it "fail" do
        auth_post(
          "/admin_api/v1/roles",
          params: params,
          headers: { "Current-Role-Id" => 2 }
        )

        assert_response :bad_request
      end
    end
  end

  describe "GET /admin_api/v1/roles/:id" do
    it "succeed" do
      auth_get "/admin_api/v1/roles/2", headers: { "Current-Role-Id" => 2 }

      assert_response :success
      assert_not_empty json_resp
    end

    it "fail with not found" do
      auth_get("/admin_api/v1/roles/0", headers: { "Current-Role-Id" => 2 })

      assert_response :not_found
    end
  end

  describe "PUT /admin_api/v1/roles/:id" do
    it "succedd" do
      auth_put(
        "/admin_api/v1/roles/2",
        params: {
          name: "role"
        },
        headers: { "Current-Role-Id" => 2 }
      )

      assert_response :success
    end

    [
      {
        name: ""
      }
    ].each do |params|
      it "fail" do
        auth_put(
          "/admin_api/v1/roles/2",
          params: params,
          headers: { "Current-Role-Id" => 2 }
        )

        assert_response :bad_request
      end
    end
  end

  describe "DELETE /admin_api/v1/roles/:id" do
    it "succeed" do
      auth_delete("/admin_api/v1/roles/2", headers: { "Current-Role-Id" => 2 })

      assert_response :success
    end

    it "fail with not found" do
      auth_delete("/admin_api/v1/roles/0")

      assert_response :not_found
    end
  end
end
