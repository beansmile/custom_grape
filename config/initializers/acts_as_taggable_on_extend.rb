# frozen_string_literal: true
ActsAsTaggableOn::Tagging.class_eval do
  before_create :set_application_id

  private
  def set_application_id
    self.application_id = taggable.application_id if taggable && taggable.respond_to?(:application_id)
  end
end
