# frozen_string_literal: true

# TODO: add active boolean (or use employee connection to disable a user)

class User < ApplicationRecord
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
end
