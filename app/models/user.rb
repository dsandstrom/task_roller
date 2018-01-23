# frozen_string_literal: true

# TODO: add Admin type,

class User < ApplicationRecord
  VALID_EMPLOYEE_TYPES = %w[Reporter Reviewer Worker].freeze

  belongs_to :employee, dependent: :destroy, required: false

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :employee, presence: true, if: :employee_id
  validates :employee_type, inclusion: { in: VALID_EMPLOYEE_TYPES }, on: :create

  before_create :create_employee

  attr_accessor :employee_type

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

  private

    def create_employee
      self.employee =
        case employee_type
        when 'Reporter'
          Reporter.create
        when 'Reviewer'
          Reviewer.create
        when 'Worker'
          Worker.create
        end
    end
end
