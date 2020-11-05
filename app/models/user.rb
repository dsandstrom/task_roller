# frozen_string_literal: true

# TODO: allow admins to upgrade/downgrade employee connection
# TODO: use employee connection to disable users
# they can't log in, but allow admin to disable/enable connection
# TODO: add priority column to use for ordering
# TODO: user subscription?

class User < ApplicationRecord # rubocop:disable Metrics/ClassLength
  VALID_EMPLOYEE_TYPES = %w[Admin Reviewer Worker Reporter].freeze
  ASSIGNABLE_EMPLOYEE_TYPES = %w[Reviewer Worker].freeze

  has_many :task_assignees, foreign_key: :assignee_id, inverse_of: :assignee,
                            dependent: :destroy
  has_many :assignments, through: :task_assignees, class_name: 'Task',
                         source: :task
  has_many :progressions, dependent: :destroy
  # TODO: accomodate destroyed user issues/tasks
  # remove employee connection instead of destroying
  # probably add paper_trail too
  has_many :issues
  has_many :tasks
  has_many :issue_comments
  has_many :task_comments
  has_many :reviews
  has_many :issue_subscriptions, dependent: :destroy
  has_many :subscribed_issues, through: :issue_subscriptions, source: :issue
  has_many :task_subscriptions, dependent: :destroy
  has_many :subscribed_tasks, through: :task_subscriptions, source: :task
  has_many :category_issues_subscriptions, dependent: :destroy
  has_many :subscribed_issue_categories,
           through: :category_issues_subscriptions,
           source: :category
  has_many :subscribed_task_categories,
           through: :category_tasks_subscriptions,
           source: :category
  has_many :category_tasks_subscriptions, dependent: :destroy
  has_many :project_issues_subscriptions, dependent: :destroy
  has_many :project_tasks_subscriptions, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :employee_type, inclusion: { in: VALID_EMPLOYEE_TYPES },
                            allow_nil: false, on: :create
  validates :employee_type, inclusion: { in: VALID_EMPLOYEE_TYPES },
                            allow_nil: true, on: :update

  # CLASS

  def self.employees(type = nil)
    if type.blank?
      where('employee_type IN (?)', VALID_EMPLOYEE_TYPES)
    elsif type.instance_of?(Array)
      return none unless type.all? { |t| VALID_EMPLOYEE_TYPES.include?(t) }

      where('employee_type IN (?)', type)
    else
      return none unless VALID_EMPLOYEE_TYPES.include?(type)

      where('employee_type = ?', type)
    end
  end

  def self.admins
    where(employee_type: 'Admin')
  end

  def self.reporters
    where(employee_type: 'Reporter')
  end

  def self.reviewers
    where(employee_type: 'Reviewer')
  end

  def self.workers
    where(employee_type: 'Worker')
  end

  # used in task filter form to display unassigned tasks
  def self.unassigned
    new(id: 0, name: '~ Unassigned ~')
  end

  def self.assignable_employees
    employees(ASSIGNABLE_EMPLOYEE_TYPES)
  end

  def self.destroyed_name
    'removed'
  end

  # INSTANCE

  def admin?
    employee_type == 'Admin'
  end

  def reviewer?
    employee_type == 'Reviewer'
  end

  def worker?
    employee_type == 'Worker'
  end

  def reporter?
    employee_type == 'Reporter'
  end

  def employee?
    return false unless employee_type

    VALID_EMPLOYEE_TYPES.include?(employee_type)
  end

  def name_and_email
    @name_and_email ||=
      if name && email
        "#{name} (#{email})"
      elsif name
        name
      else
        email
      end
  end

  def name_or_email
    @name_or_email ||= (name || email)
  end

  def task_progressions(task)
    progressions.where(task_id: task.id).order(created_at: :asc)
  end

  # group up progression dates to make something readable
  # TODO: "3/5-3/6, 3/7-3/8" -> "3/5-3/8"
  # TODO: "3/6, 3/6-3/8" -> "3/6-3/8"
  # TODO: finished only? ("3/6-")
  def task_progress(task)
    task_progressions(task).map do |progression|
      start_date = progression.start_date
      finish_date = progression.finish_date

      if start_date == finish_date
        start_date
      else
        "#{start_date}-#{finish_date}"
      end
    end.uniq.join(', ')
  end

  # used by Task#finish_progressions
  def finish_progressions
    progressions.unfinished.each(&:finish)
  end

  # order by:
  # task has open progression by user
  # task has progressions by user
  # no progressions or reviews
  # pending review
  # comment by another user
  # should order last by tasks.created_at asc?
  ACTIVE_ASSIGNMENTS_QUERY =
    'tasks.*, ' \
    'SUM(case when progressions.finished IS FALSE then 1 else 0 end) ' \
    'AS unfinished_progressions_count, ' \
    'COUNT(progressions.id) AS progressions_count, ' \
    'SUM(case when reviews.id IS NOT NULL AND reviews.approved IS NULL ' \
    'then 1 else 0 end) AS pending_reviews_count, ' \
    'COALESCE(MAX(roller_comments.created_at), MAX(progressions.created_at), ' \
    'tasks.created_at) AS order_date'
  ACTIVE_ASSIGNMENTS_ORDER =
    { unfinished_progressions_count: :desc, pending_reviews_count: :asc,
      progressions_count: :desc, order_date: :desc }.freeze
  def active_assignments
    @active_assignments ||=
      assignments
      .left_joins(:progressions, :reviews, :comments).references(:comments)
      .all_open.select(ACTIVE_ASSIGNMENTS_QUERY)
      .where('roller_comments.id IS NULL OR roller_comments.user_id != ?', id)
      .group(:id).order(ACTIVE_ASSIGNMENTS_ORDER)
  end

  # TODO: add recently addressed issues?
  # for reporters/show view
  # link to user/issues which will be filterable
  UNRESOLVED_ISSUES_ORDER =
    { open_tasks_count: :desc, tasks_count: :desc, order_date: :desc }.freeze
  UNRESOLVED_ISSUES_QUERY =
    'issues.*, ' \
    'COALESCE(MAX(roller_comments.created_at), issues.created_at) AS order_date'
  def unresolved_issues
    @unresolved_issues ||=
      issues
      .all_unresolved.left_joins(:comments).references(:comments)
      .select(UNRESOLVED_ISSUES_QUERY)
      .where('roller_comments.id IS NULL OR roller_comments.user_id != ?', id)
      .group(:id).order(UNRESOLVED_ISSUES_ORDER)
  end

  # priority:
  # in review
  # in progress
  # assigned
  # open
  #
  # order:
  # comment by another user, progression, created_at
  OPEN_TASKS_QUERY =
    'tasks.*, ' \
    'COUNT(progressions.id) AS progressions_count, ' \
    'SUM(case when reviews.id IS NOT NULL AND reviews.approved IS NULL ' \
    'then 1 else 0 end) AS pending_reviews_count, ' \
    'COALESCE(MAX(roller_comments.created_at), MAX(progressions.created_at), ' \
    'tasks.created_at) AS order_date'
  OPENS_TASKS_ORDER =
    { pending_reviews_count: :desc, progressions_count: :desc,
      order_date: :desc }.freeze
  def open_tasks
    @open_tasks ||=
      tasks
      .all_open.select(OPEN_TASKS_QUERY)
      .left_joins(:progressions, :reviews, :comments).references(:comments)
      .where('roller_comments.id IS NULL OR roller_comments.user_id != ?', id)
      .group(:id).order(OPENS_TASKS_ORDER)
  end

  # TODO: tasks from a user's open issues
  # for reporters/show view
  # def tasks_from_open_issues
  #   # code
  # end
end
