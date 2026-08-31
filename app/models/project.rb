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

  acts_as_list scope: :category_id

  attr_accessor :new_position

  validates :name, presence: true, length: { maximum: 250 },
                   uniqueness: { scope: :category_id, case_sensitive: false }
  validate :new_position_numericality

  # CLASS

  def self.all_visible
    where(visible: true).order(:position)
  end

  def self.all_invisible
    where(visible: false).order(:position)
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

  def reposition
    return false if new_position.blank?

    insert_at(new_position) || false
  rescue ArgumentError => e
    logger.debug "ArgumentError: #{e}"
    false
  end

  private

    def max_position
      @max_position ||= category&.projects&.count
    end

    def new_position_ready?
      new_position.present? && !!max_position
    end

    def new_position_numericality
      return unless new_position_ready?

      unless new_position.instance_of?(Integer)
        return errors.add(:new_position, 'must be an integer')
      end

      unless new_position.positive?
        return errors.add(:new_position, 'must greater than 0')
      end

      return unless new_position > max_position

      errors.add(:new_position, "must less than #{max_position + 1}")
    end

    def build_name_and_tag
      tags = []

      tags << 'archived' unless visible? && category.visible?
      tags << 'internal' if internal? || category.internal?

      "#{name}#{" (#{tags.join(', ')})" if tags.any?}"
    end
end
