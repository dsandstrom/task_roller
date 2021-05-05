# frozen_string_literal: true

# TODO: add 'assigned to you' status?

class Task < ApplicationRecord # rubocop:disable Metrics/ClassLength
  DEFAULT_ORDER = 'tasks.updated_at desc'
  STATUS_OPTIONS = {
    open: { color: 'green' },
    assigned: { color: 'blue' },
    in_progress: { color: 'yellow' },
    in_review: { color: 'purple' },
    approved: { color: 'blue' },
    duplicate: { color: 'brown' },
    closed: { color: 'red' }
  }.freeze

  belongs_to :user
  belongs_to :task_type
  belongs_to :project
  belongs_to :issue, required: false, counter_cache: true
  has_many :task_assignees, dependent: :destroy
  has_many :assignees, through: :task_assignees,
                       before_remove: :finish_assignee_progressions
  has_many :progressions, dependent: :destroy
  has_many :progression_users, through: :progressions, source: :user
  has_many :reviews, dependent: :destroy
  has_many :comments, class_name: 'TaskComment', foreign_key: :task_id,
                      dependent: :destroy, inverse_of: :task
  delegate :category, to: :project

  has_one :source_connection, class_name: 'TaskConnection',
                              foreign_key: :source_id, dependent: :destroy,
                              inverse_of: :source
  # TODO: add better name
  has_one :duplicatee, through: :source_connection, class_name: 'Task',
                       source: :target
  has_many :target_connections, class_name: 'TaskConnection',
                                foreign_key: :target_id,
                                dependent: :destroy, inverse_of: :target
  has_many :duplicates, through: :target_connections, class_name: 'Task',
                        source: :source
  has_many :task_subscriptions, dependent: :destroy
  has_many :subscribers, through: :task_subscriptions, source: :user
  has_many :closures, class_name: 'TaskClosure'
  has_many :reopenings, class_name: 'TaskReopening'
  has_many :notifications, class_name: 'TaskNotification', dependent: :destroy

  accepts_nested_attributes_for :assignees

  validates :summary, presence: true, length: { maximum: 200 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :user_id, presence: true
  validates :user, presence: true, if: :user_id
  validates :task_type_id, presence: true
  validates :task_type, presence: true, if: :task_type_id
  validates :project_id, presence: true
  validates :project, presence: true, if: :project_id
  validates :status, inclusion: { in: STATUS_OPTIONS.keys.map(&:to_s) },
                     allow_nil: true

  after_create :set_opened_at
  after_save :update_issue_counts

  # CLASS

  def self.all_non_closed
    where(closed: false)
  end

  def self.all_closed
    where(closed: true)
  end

  def self.all_open
    all_non_closed.where(status: 'open')
  end

  def self.all_assigned
    all_non_closed.where(status: 'assigned')
  end

  def self.all_in_progress
    all_non_closed.where(status: 'in_progress')
  end

  def self.all_in_review
    all_non_closed.where(status: 'in_review')
  end

  # TODO: change to all_completed
  def self.all_approved
    all_closed.where(status: 'approved')
  end

  def self.all_duplicate
    all_closed.where(status: 'duplicate')
  end

  # TODO: order open issues first by default
  def self.filter_by(filters = {})
    id, query = SearchResult.split_id(filters[:query])

    includes(task_assignees: :assignee, issue: :user)
      .filter_by_status(filters[:task_status])
      .filter_by_type(filters[:task_type_id])
      .filter_by_id(id)
      .filter_by_string(query)
      .filter_by_assigned_id(filters[:assigned])
      .order(build_order_param(filters[:order]))
  end

  # used by .filter_by
  def self.filter_by_status(status)
    return all unless status

    options = STATUS_OPTIONS.keys
    return all unless options.include?(status.to_sym)

    send("all_#{status}")
  end

  # used by .filter_by
  def self.filter_by_assigned_id(assigned_id)
    return all if assigned_id.blank?

    if assigned_id == User.unassigned.id.to_s
      where('task_assignees.assignee_id IS NULL')
        .references(:task_assignees)
    else
      where('task_assignees.assignee_id = ?', assigned_id)
        .references(:task_assignees)
    end
  end

  # used by .filter_by
  # TODO: search text in associated comments too (comments.body)
  def self.filter_by_string(query)
    return all if query.blank?

    where('tasks.summary ILIKE :query OR tasks.description ILIKE :query',
          query: "%#{query}%")
  end

  # used by .filter_by
  def self.build_order_param(order)
    return DEFAULT_ORDER if order.blank?

    column, direction = order.split(',')
    return DEFAULT_ORDER unless direction &&
                                %w[created updated].include?(column) &&
                                %w[asc desc].include?(direction)

    "tasks.#{column}_at #{direction}"
  end

  def self.filter_by_type(task_type_id)
    return all if task_type_id.blank?
    return none unless TaskType.find_by(id: task_type_id)

    where(task_type_id: task_type_id)
  end

  # TODO: include tasks thru task_connections, but order id match first
  def self.filter_by_id(query)
    return all if query.blank?

    where(id: query.to_i)
  end

  def self.all_visible
    joins(:project, project: :category)
      .where('projects.visible = :visible AND categories.visible = :visible',
             visible: true)
  end

  def self.all_invisible
    joins(:project, project: :category)
      .where('projects.visible = :visible OR categories.visible = :visible',
             visible: false)
  end

  # INSTANCE

  def description_html
    @description_html ||= (RollerMarkdown.new.render(description) || '')
  end

  def short_summary
    @short_summary ||= summary&.truncate(70)
  end

  def id_and_summary
    @id_and_summary ||= ("##{id} - #{short_summary}" if id && summary.present?)
  end

  def heading
    @heading ||= ("Task \##{id}: #{summary}" if id && summary.present?)
  end

  def open?
    !closed?
  end

  # TODO: add options to categories/projects on which users are assignable
  def assignable
    @assignable ||= User.assignable_employees
  end

  def reviewable
    @reviewable ||= User.reviewers
  end

  # users from progressions that aren't current assignees
  def assigned
    @assigned ||= User.assigned_to(self)
  end

  def user_form_options
    @user_form_options ||=
      %w[Admin Reviewer].map do |type|
        [type, User.employees(type).map { |u| [u.name_and_email, u.id] }]
      end
  end

  def concluded_reviews
    if @concluded_reviews.instance_of?(ActiveRecord::AssociationRelation)
      return @concluded_reviews
    end

    @concluded_reviews = reviews.concluded.order('reviews.updated_at asc')
  end

  def current_reviews
    if @current_reviews.instance_of?(ActiveRecord::AssociationRelation)
      return @current_reviews
    end

    @current_reviews = reviews.where('reviews.created_at > ?', opened_at)
  end

  def current_review
    @current_review ||= current_reviews.order(created_at: :desc).first
  end

  def finish
    progressions&.unfinished&.all?(&:finish)
  end

  def close(current_user = nil)
    reviews.pending.each { |r| r.update(approved: false) }
    return false unless finish

    update closed: true
    update_status(current_user)
    close_issue(current_user)
  end

  # TODO: show outdated reviews in history
  def reopen(current_user = nil)
    return false unless update(closed: false, opened_at: Time.now)

    update_status(current_user)
    return true unless issue&.closed?

    issue.reopen(current_user)
  end

  def subscribe_user(subscriber = nil)
    subscriber ||= user
    return unless subscriber

    task_subscriptions.create(user_id: subscriber.id)
  end

  def subscribe_assignees
    return unless assignees

    assignees.each { |u| task_subscriptions.create(user_id: u.id) }
  end

  # TODO: use ActiveJob
  def subscribe_users
    subscribe_user
    subscribe_assignees
    category.task_subscribers.each { |u| subscribe_user(u) }
    project.task_subscribers.each { |u| subscribe_user(u) }
  end

  # feed of closures, reopenings, duplicate, tasks, reviews
  def history_feed
    @history_feed ||= build_history_feed
  end

  def assigned_at(assignee)
    task_assignees.where(assignee_id: assignee.id).minimum(:created_at)
  end

  def siblings
    @siblings ||= issue&.tasks&.where&.not(id: id)
  end

  # rubocop:disable Naming/MemoizedInstanceVariableName
  def in_review?
    @in_review_ ||= status == 'in_review'
  end

  def in_progress?
    @in_progress_ ||= status == 'in_progress'
  end

  def assigned?
    @assigned_ ||= status == 'assigned'
  end

  def unassigned?
    @unassigned_ ||= status == 'open'
  end

  def approved?
    @approved_ ||= status == 'approved'
  end

  def duplicate?
    @duplicate_ ||= status == 'duplicate'
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName

  def update_status(current_user = nil)
    old_status = status
    update_column :status, build_status
    return true if old_status == status

    options = notification_options(old_status)
    options[:current_user] = current_user if current_user.present?
    notify_subscribers(options)
  end

  def notify_of_comment(options)
    comment = options.delete(:comment)
    return unless comment

    options[:task_comment] = comment
    options[:current_user] =
      if options[:current_user]
        [options[:current_user], comment.user]
      else
        comment.user
      end

    notify_subscribers(options.merge(event: 'comment'))
  end

  private

    # - closed
    # - open
    #   - reviews open = 'in review'
    #   - progressions unfinished = 'in progress'
    #   - any assignees = 'assigned'
    #   - unassigned
    def build_status
      if closed?
        closed_status
      else
        open_status
      end
    end

    def open_status
      if any_pending_reviews?
        'in_review'
      elsif unfinished_progressions? ||
            (any_assignees? && status == 'in_progress')
        'in_progress'
      elsif any_assignees?
        'assigned'
      else
        'open'
      end
    end

    def closed_status
      if approved_review?
        'approved'
      elsif source_connection?
        'duplicate'
      else
        'closed'
      end
    end

    def any_pending_reviews?
      open? && current_reviews.pending.any?
    end

    def unfinished_progressions?
      open? && progressions.unfinished.any?
    end

    def any_assignees?
      open? && assignees.any?
    end

    def approved_review?
      current_review&.approved?
    end

    def source_connection?
      source_connection.present?
    end

    def finish_assignee_progressions(assignee)
      assignee.finish_progressions
    end

    def set_opened_at
      return if opened_at.present? || created_at.nil?

      update_column :opened_at, created_at
    end

    def last_task_for_issue?
      issue.open_tasks.where('tasks.id != ?', id).none?
    end

    def close_issue(current_user = nil)
      return true unless issue && last_task_for_issue?

      issue.close(current_user)
    end

    def update_issue_counts
      return unless issue

      issue.update_column :open_tasks_count, issue.tasks.all_non_closed.count
    end

    def subscribers_except(users)
      if users
        if users.is_a?(Array)
          subscribers.where.not(id: users.map(&:id))
        else
          subscribers.where.not(id: users.id)
        end
      else
        subscribers
      end
    end

    # TODO: add assigned, or progressions grouped by user
    def build_history_feed
      feed = []
      [closures, reopenings, concluded_reviews].each do |collection|
        feed << collection if collection.any?
      end
      feed << source_connection if source_connection
      feed.flatten.sort_by(&:created_at)
    end

    def notify_subscribers(options)
      current_user = options.delete(:current_user)
      subscribers_except(current_user).each do |subscriber|
        notify_subscriber(subscriber, options)
      end
      true
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.debug "TaskNotification invalid:\n#{e.inspect}"
      false
    end

    def notify_subscriber(subscriber, options)
      if options[:event] == 'status'
        notification = notifications.find_by(user_id: subscriber.id,
                                             event: 'status')
      end
      if notification
        notification.update options
      else
        notification = notifications.create!(options.merge(user: subscriber))
      end
      notification.send_email
    end

    def notification_options(old_status)
      if old_status.present?
        { event: 'status', details: "#{old_status},#{status}" }
      else
        { event: 'new' }
      end
    end
end
