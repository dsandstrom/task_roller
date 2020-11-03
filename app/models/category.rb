# frozen_string_literal: true

# TODO: add friendly_id/slug
# TODO: add icon options
# TODO: add image
# TODO: force moving projects before destroying

class Category < ApplicationRecord
  has_many :projects, dependent: :destroy
  has_many :issues, through: :projects
  has_many :tasks, through: :projects
  has_many :category_issue_subscriptions, dependent: :destroy
  has_many :category_task_subscriptions, dependent: :destroy
  has_many :issue_subscribers, through: :category_issue_subscriptions,
                               foreign_key: :user_id, source: :user
  has_many :task_subscribers, through: :category_task_subscriptions,
                              foreign_key: :user_id, source: :user

  validates :name, presence: true, length: { maximum: 200 }
end
