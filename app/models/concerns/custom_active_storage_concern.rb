# frozen_string_literal: true

module CustomActiveStorageConcern
  extend ActiveSupport::Concern

  module ClassMethods
    # https://github.com/rails/rails/blob/fbe2433be6e052a1acac63c7faf287c52ed3c5ba/activestorage/lib/active_storage/attached/model.rb#L89
    # 重写的地方注释
    def custom_has_many_attached(name, dependent: :purge_later)
      generated_association_methods.class_eval <<-CODE, __FILE__, __LINE__ + 1
        def #{name}
          @active_storage_attached_#{name} ||= ActiveStorage::Attached::Many.new("#{name}", self)
        end

        def #{name}=(attachables)
          if ActiveStorage.replace_on_assign_to_many
            attachment_changes["#{name}"] =
              if Array(attachables).none?
                ActiveStorage::Attached::Changes::DeleteMany.new("#{name}", self)
              else
                ActiveStorage::Attached::Changes::CreateMany.new("#{name}", self, attachables)
              end
          else
            if Array(attachables).any?
              attachment_changes["#{name}"] =
                ActiveStorage::Attached::Changes::CreateMany.new("#{name}", self, #{name}.blobs + attachables)
            end
          end
        end
      CODE

      # 重写：增加了order(:position)
      has_many :"#{name}_attachments", -> { where(name: name).order(:position) }, as: :record, class_name: "ActiveStorage::Attachment", inverse_of: :record, dependent: :destroy do
        def purge
          each(&:purge)
          reset
        end

        def purge_later
          each(&:purge_later)
          reset
        end
      end
      has_many :"#{name}_blobs", through: :"#{name}_attachments", class_name: "ActiveStorage::Blob", source: :blob

      scope :"with_attached_#{name}", -> { includes("#{name}_attachments": :blob) }

      after_save do
        attachment_changes[name.to_s]&.save

        # 重写：增加了排序处理
        if attachment_changes[name.to_s]
          attachment_changes[name.to_s].attachments.each_with_index do |attachment, index|
            attachment.update(position: index + 1)
          end
        end
      end

      after_commit(on: %i[ create update ]) { attachment_changes.delete(name.to_s).try(:upload) }

      ActiveRecord::Reflection.add_attachment_reflection(
        self,
        name,
        ActiveRecord::Reflection.create(:has_many_attached, name, nil, { dependent: dependent }, self)
      )
    end
  end
end
