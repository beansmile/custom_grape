# frozen_string_literal: true

module Bean
  module DraftResourceConcern
    extend ActiveSupport::Concern

    module ClassMethods
      def set_draft_version_handling_methods(resource_name:)
        # admin编辑的是草稿版，删除草稿版的话正式版也得一起删除
        has_one "formal_#{resource_name}".to_sym, class_name: self.name, foreign_key: "draft_#{resource_name}_id".to_sym, dependent: :destroy
        belongs_to "draft_#{resource_name}".to_sym, class_name: self.name, optional: true

        scope :draft, -> { where({ "draft_#{resource_name}_id" => nil }) }
        scope :formal, -> { where.not({ "draft_#{resource_name}_id" => nil }) }

        # 新建草稿版后，创建对应正式版
        define_method "create_with_formal_#{resource_name}" do
          begin
            transaction do
              self.save!

              # 只有草稿版可以创建正式版；只能创建一个正式版
              if draft_resource_id.blank? && formal_resource.blank?
                formal_resource = self.send("build_formal_#{resource_name}", self.dup_attributes)
                unless formal_resource.save
                  errors.add(:base, formal_resource.errors.full_messages.join(", "))
                  raise ActiveRecord::RecordInvalid
                end
              end
            end
          rescue ActiveRecord::RecordInvalid
            return false
          end

          return true
        end

        define_method "dup_attributes" do
          self.attributes.except("id", "updated_at", "created_at").merge({ "latest_sync_time" => updated_at, "draft_#{resource_name}_id" => id })
        end

        define_method "draft_resource_id" do
          @draft_resource_id ||= send("draft_#{resource_name}_id")
        end

        define_method "formal_resource" do
          @formal_resource ||= send("formal_#{resource_name}")
        end

        # 草稿版数据是否可回退到正式版
        define_method "can_rollback_data?" do
          draft_resource_id.blank? && updated_at != formal_resource&.latest_sync_time
        end

        define_method "rollback_data" do
          begin
            transaction do
              if can_rollback_data?
                update!(formal_resource.dup_attributes.merge({ "draft_#{resource_name}_id" => nil }))
                unless formal_resource.update(latest_sync_time: updated_at)
                  errors.add(:base, formal_resource.errors.full_messages.join(", "))
                  raise ActiveRecord::RecordInvalid
                end
              end
            end
          rescue ActiveRecord::RecordInvalid
            return false
          end

          return true
        end
      end
    end
  end
end
