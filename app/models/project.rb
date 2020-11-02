# frozen_string_literal: true

# TODO: add ProjectSubscription
# TODO: add friendly_id/slug
# TODO: add icon options
# TODO: add image
# TODO: force moving issues/tasks before destroying

class Project < ApplicationRecord
  belongs_to :category
  has_many :issues, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :project_issue_subscriptions, dependent: :destroy
  has_many :project_task_subscriptions, dependent: :destroy

  validates :name, presence: true, length: { maximum: 250 },
                   uniqueness: { scope: :category_id, case_sensitive: false }
  validates :category_id, presence: true
  validates :category, presence: true, if: :category_id
end
