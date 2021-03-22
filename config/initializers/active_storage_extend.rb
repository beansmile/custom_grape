# frozen_string_literal: true
Rails.application.config.to_prepare do
  ActiveStorage::Blob.class_eval do
    acts_as_taggable_on :tags

    # 由于acts-as-taggable-on提供的tag_list方法难以避免N+1问题，所以这里增加一个custom_tag_list来避免
    def custom_tag_list
      tags.map(&:name)
    end
  end
end
