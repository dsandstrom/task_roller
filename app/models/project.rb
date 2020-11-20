# frozen_string_literal: true

# TODO: add friendly_id/slug
# TODO: add icon options
# TODO: add image
# TODO: force moving issues/tasks before destroying
# TODO: add way to archive (or use visible for that)

class Project < ApplicationRecord
  belongs_to :category
  has_many :issues, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :project_issues_subscriptions, dependent: :destroy
  has_many :project_tasks_subscriptions, dependent: :destroy
  has_many :issue_subscribers, through: :project_issues_subscriptions,
                               foreign_key: :user_id, source: :user
  has_many :task_subscribers, through: :project_tasks_subscriptions,
                              foreign_key: :user_id, source: :user

  validates :name, presence: true, length: { maximum: 250 },
                   uniqueness: { scope: :category_id, case_sensitive: false }
  validates :category_id, presence: true
  validates :category, presence: true, if: :category_id

  def issues_subscription(user, options = {})
    method =
      if options[:init] == true
        :find_or_initialize_by
      else
        :find_by
      end
    project_issues_subscriptions.send(method, user_id: user.id)
  end

  def tasks_subscription(user, options = {})
    method =
      if options[:init] == true
        :find_or_initialize_by
      else
        :find_by
      end
    project_tasks_subscriptions.send(method, user_id: user.id)
  end

  def subscribed_to_issues?(user)
    issues_subscription(user).present?
  end

  def subscribed_to_tasks?(user)
    tasks_subscription(user).present?
  end
end
