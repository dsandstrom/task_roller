# frozen_string_literal: true

class User < ApplicationRecord
  VALID_EMPLOYEE_TYPES = %w[Admin Reporter Reviewer Worker].freeze

  belongs_to :employee, dependent: :destroy, required: false
  has_many :task_assignees, foreign_key: :assignee_id, inverse_of: :assignee,
                            dependent: :destroy
  has_many :assignments, through: :task_assignees, class_name: 'Task',
                         source: :task

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :employee, presence: true, if: :employee_id
  validates :employee_type, inclusion: { in: VALID_EMPLOYEE_TYPES }, on: :create

  before_create :create_employee

  attr_writer :employee_type

  # CLASS

  def self.employees(type = nil)
    if type
      return none unless VALID_EMPLOYEE_TYPES.include?(type)
      return where('employees.type = ?', type).includes(:employee)
                                              .references(:employees)
    end

    where('employees.type IN (?)', VALID_EMPLOYEE_TYPES).includes(:employee)
                                                        .references(:employees)
  end

  def self.admins
    employees('Admin')
  end

  def self.reporters
    employees('Reporter')
  end

  def self.reviewers
    employees('Reviewer')
  end

  def self.workers
    employees('Worker')
  end

  # INSTANCE

  def employee_type
    @employee_type ||= employee&.type
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
    @name_or_email ||= (name ? name : email)
  end

  private

    def create_employee
      return if employee_type.blank?
      self.employee = employee_type.constantize.create
    end
end
