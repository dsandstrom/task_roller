# frozen_string_literal: true

class User < ApplicationRecord
  VALID_EMPLOYEE_TYPES = %w[Admin Reporter Reviewer Worker].freeze

  belongs_to :employee, dependent: :destroy, required: false

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :employee, presence: true, if: :employee_id
  validates :employee_type, inclusion: { in: VALID_EMPLOYEE_TYPES }, on: :create

  before_create :create_employee

  attr_writer :employee_type

  # CLASS

  def self.admins
    where("employees.type = 'Admin'").includes(:employee)
                                     .references(:employees)
  end

  def self.reporters
    where("employees.type = 'Reporter'").includes(:employee)
                                        .references(:employees)
  end

  def self.reviewers
    where("employees.type = 'Reviewer'").includes(:employee)
                                        .references(:employees)
  end

  def self.workers
    where("employees.type = 'Worker'").includes(:employee)
                                      .references(:employees)
  end

  def self.employees
    where('employees.type IN (?)', VALID_EMPLOYEE_TYPES).includes(:employee)
                                                        .references(:employees)
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
