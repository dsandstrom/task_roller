# frozen_string_literal: true

# TODO: allow admins to upgrade/downgrade employee connection
# TODO: use employee connection to disable users
# they can't log in, but allow admin to disable/enable connection

class User < ApplicationRecord
  VALID_EMPLOYEE_TYPES = %w[Admin Reviewer Worker Reporter].freeze
  ASSIGNABLE_EMPLOYEE_TYPES = %w[Reviewer Worker].freeze
  # OPEN_ISSUES_ORDER = { open_tasks_count: :desc, tasks_count: :desc,
  #                       created_at: :desc }.freeze

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
  has_many :issue_subscriptions, foreign_key: :user_id, dependent: :destroy
  has_many :subscribed_issues, through: :issue_subscriptions,
                               foreign_key: :issue_id, class_name: 'Issue'

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

  # auto subscribe created issues, after comment, assign task
  # order by status, new comments
  # allow customize when subscription created
  # def subscribed_issues
  # end

  # user/issues will show all and allow subscring/unsub
  # show open issues that are subscribed
  # def associated_issues
  # end

  # link to user/tasks with all associated
  # assigned_tasks, with progressions
  # def subscribed_tasks
  # end

  # their tasks, assigned tasks
  # def associated_tasks
  # end

  # for reporters/show view
  # link to user/issues which will be filterable
  # TODO: order by new comments (not made by user)?
  # def open_issues
  #   @open_issues ||= issues.all_non_closed.order(OPEN_ISSUES_ORDER)
  # end

  # for reporters/show view
  # # TODO: tasks from a user's open issues
  # def tasks_from_open_issues
  #   # code
  # end
  #
  # def tasks_ready_for_review
  #   # code
  #   open_tasks.all_in_review
  # end
  #
  # # filter by in progress (show at top or separately)
  # # priotorize by open progression
  # def assigned_tasks
  #   open_tasks.where('task_assignees.assignee_id = ?', id)
  #             .joins(:task_assignees)
  # end
  #
  # # TODO: no pending review
  # def tasks_in_progress
  #   open_tasks.where('progressions.user_id = ?', id)
  #             .joins(:progressions)
  # end
  #
  # def reviewed_tasks
  # end
end
