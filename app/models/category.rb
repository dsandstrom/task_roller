# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :projects, dependent: :destroy
  has_many :issues, through: :projects
  has_many :tasks, through: :projects
  has_many :category_issues_subscriptions, dependent: :destroy
  has_many :category_tasks_subscriptions, dependent: :destroy
  has_many :issue_subscribers, through: :category_issues_subscriptions,
                               foreign_key: :user_id, source: :user
  has_many :task_subscribers, through: :category_tasks_subscriptions,
                              foreign_key: :user_id, source: :user

  validates :name, presence: true, length: { maximum: 200 }

  # CLASS

  def self.all_visible
    where(visible: true)
  end

  def self.all_invisible
    where(visible: false)
  end

  # INSTANCE

  def issues_subscription(user, options = {})
    method =
      if options[:init] == true
        :find_or_initialize_by
      else
        :find_by
      end
    category_issues_subscriptions.send(method, user_id: user.id)
  end

  def tasks_subscription(user, options = {})
    method =
      if options[:init] == true
        :find_or_initialize_by
      else
        :find_by
      end
    category_tasks_subscriptions.send(method, user_id: user.id)
  end

  def subscribed_to_issues?(user)
    issues_subscription(user).present?
  end

  def subscribed_to_tasks?(user)
    tasks_subscription(user).present?
  end

  def name_and_tag
    @name_and_tag ||= "#{name}#{' (archived)' unless visible?}"
  end
end
