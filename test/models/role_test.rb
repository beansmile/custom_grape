# frozen_string_literal: true
require "test_helper"

class RoleTest < ActiveSupport::TestCase
  let(:role) { roles(:one) }

  describe "validations" do
    it "is valid" do
      assert role.valid?
    end

    it "has name" do
      role.name = nil

      assert_not role.valid?
    end

    it "has unique name" do
      assert_raises(ActiveRecord::RecordInvalid) { Role.create!(name: role.name) }
    end
  end

  describe "class methods" do
    describe ".permissions_hash" do
      it "is present" do
        assert_not_empty Role.permissions_hash
      end
    end

    # describe ".build_permissions_array_data" do
      # it "return present collection" do
        # assert_not_empty Role.build_permissions_array_data(Role.new.permissions)
      # end
    # end
  end

  describe "instance methods" do
    describe "#permissions_attributes" do
      it "is present" do
        assert_not_empty role.permissions_attributes
      end
    end
  end
end
