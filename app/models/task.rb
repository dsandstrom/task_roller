# frozen_string_literal: true

# TODO: if closed with no approved review = rejected/ won't fix
# TODO: create task reopens issue?
# TODO: show other tasks from issue
# TODO: allow self-assigning for worker+
# TODO: allow reviewer+ to change project (any category)

class Task < ApplicationRecord # rubocop:disable Metrics/ClassLength
  DEFAULT_ORDER = 'tasks.updated_at desc'
  STATUS_OPTIONS = {
    open: { color: 'green' },
    unassigned: { color: 'purple' },
    assigned: { color: 'blue' },
    in_progress: { color: 'yellow' },
    in_review: { color: 'brown' },
    approved: { color: 'blue' },
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
  has_many :reviews, dependent: :destroy
  has_many :comments, class_name: 'TaskComment', foreign_key: :task_id,
                      dependent: :destroy, inverse_of: :task
  delegate :category, to: :project

  has_one :source_task_connection, class_name: 'TaskConnection',
                                   foreign_key: :source_id, dependent: :destroy,
                                   inverse_of: :source
  # TODO: add better name
  has_one :duplicatee, through: :source_task_connection, class_name: 'Task',
                       source: :target
  has_many :target_task_connections, class_name: 'TaskConnection',
                                     foreign_key: :target_id,
                                     dependent: :destroy, inverse_of: :target
  has_many :duplicates, through: :target_task_connections, class_name: 'Task',
                        source: :source
  has_many :task_subscriptions, dependent: :destroy
  has_many :subscribers, through: :task_subscriptions, source: :user

  accepts_nested_attributes_for :assignees

  validates :summary, presence: true, length: { maximum: 200 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :user_id, presence: true
  validates :user, presence: true, if: :user_id
  validates :task_type_id, presence: true
  validates :task_type, presence: true, if: :task_type_id
  validates :project_id, presence: true
  validates :project, presence: true, if: :project_id

  after_create :set_opened_at
  after_save :update_issue_counts

  # CLASS

  def self.all_open
    where(closed: false)
  end

  def self.all_closed
    where(closed: true)
  end

  def self.all_in_review
    where('reviews.created_at > tasks.opened_at AND reviews.approved IS NULL')
      .joins(:reviews)
  end

  def self.all_in_progress
    where('progressions.finished = ?', false).joins(:progressions)
  end

  def self.all_assigned
    no_reviews = 'reviews.task_id IS NULL OR '\
                 'reviews.created_at < tasks.opened_at'
    no_progresions = 'progressions.task_id IS NULL OR '\
                     'progressions.finished_at < tasks.opened_at'

    all_open
      .joins(:task_assignees).left_joins(:reviews, :progressions)
      .where(no_reviews).where(no_progresions)
  end

  def self.all_unassigned
    no_assignees = 'task_assignees.task_id IS NULL'
    all_open.left_joins(:task_assignees).where(no_assignees)
  end

  # TODO: change to all_completed
  def self.all_approved
    where('reviews.created_at > tasks.opened_at AND reviews.approved = ?', true)
      .joins(:reviews)
  end

  def self.filter_by(filters = {})
    includes(task_assignees: :assignee, issue: :user)
      .apply_filters(filters)
      .order(build_order_param(filters[:order]))
      .distinct
  end

  # used by .filter
  def self.apply_filters(filters)
    tasks = all
    tasks = tasks.filter_by_status(filters[:status])
    tasks.filter_by_assigned_id(filters[:assigned])
  end

  # used by .filter
  def self.filter_by_status(status)
    return all unless status

    options = STATUS_OPTIONS.keys
    return all unless options.include?(status.to_sym)

    send("all_#{status}")
  end

  # used by .filter
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

  # used by .filter
  def self.build_order_param(order)
    return DEFAULT_ORDER if order.blank?

    column, direction = order.split(',')
    return DEFAULT_ORDER unless direction &&
                                %w[created updated].include?(column) &&
                                %w[asc desc].include?(direction)

    "tasks.#{column}_at #{direction}"
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
    @assigned ||= build_assigned
  end

  def user_form_options
    @user_form_options ||=
      %w[Admin Reviewer].map do |type|
        [type, User.employees(type).map { |u| [u.name_and_email, u.id] }]
      end
  end

  # TODO: add unassigned status
  # - closed
  # - open
  #   - reviews open = 'in review'
  #   - progressions unfinished = 'in progress'
  #   - any assignees = 'assigned'
  #   - unassigned = 'open'
  def status
    @status ||=
      if closed?
        closed_status
      else
        open_status
      end
  end

  def finish
    progressions&.unfinished&.all?(&:finish)
  end

  def close
    reviews.pending.each { |r| r.update(approved: false) }
    return false unless finish

    close_issue
    update closed: true
  end

  # TODO: show outdated reviews in history
  def reopen
    return false unless update(closed: false, opened_at: Time.now)
    return true unless issue&.closed?

    issue.reopen
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

  def in_review?
    @in_review ||= open? && current_reviews.pending.any?
  end

  def in_progress?
    @in_progress ||=
      if in_review?
        false
      else
        open? && progressions.unfinished.any?
      end
  end

  # rubocop:disable Naming/MemoizedInstanceVariableName
  def assigned?
    @assigned_ ||=
      if in_review? || in_progress?
        false
      else
        open? && assignees.any?
      end
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName

  def approved?
    @approved ||=
      if current_review.blank?
        false
      else
        current_review.approved?
      end
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

  private

    def build_assigned
      users = User.includes(:progressions).where('progressions.task_id = ?', id)
      if open? && assignee_ids.any?
        users = users.where('users.id NOT IN (?)', assignee_ids)
      end
      users.order('progressions.created_at desc')
    end

    def open_status
      if in_review?
        'in review'
      elsif in_progress?
        'in progress'
      elsif assigned?
        'assigned'
      else
        'open'
      end
    end

    def closed_status
      if approved?
        'approved'
      else
        'closed'
      end
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

    def close_issue
      return true unless issue && last_task_for_issue?

      issue.close
    end

    def update_issue_counts
      return unless issue

      issue.update_column :open_tasks_count, issue.tasks.all_open.count
    end
end
