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

  acts_as_list scope: :category

  validates :name, presence: true, length: { maximum: 250 },
                   uniqueness: { scope: :category_id, case_sensitive: false }

  # CLASS

  def self.all_visible
    where(visible: true).order(position: :asc)
  end

  def self.all_invisible
    where(visible: false).order(position: :asc)
  end

  # INSTANCE

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

  def totally_visible?
    if @totally_visible_.nil?
      @totally_visible_ = visible? && category.present? && category.visible?
    end
    @totally_visible_
  end

  def name_and_tag
    @name_and_tag ||= build_name_and_tag
  end

  private

    def build_name_and_tag
      tags = []

      tags << 'archived' unless visible? && category.visible?
      tags << 'internal' if internal? || category.internal?

      "#{name}#{" (#{tags.join(', ')})" if tags.any?}"
    end
end
