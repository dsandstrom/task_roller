# frozen_string_literal: true

class ProjectSubscription < ApplicationRecord
  validates :user_id, presence: true
  validates :project_id, presence: true
  validates :type, presence: true

  belongs_to :user
  belongs_to :project
end
