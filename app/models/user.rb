# frozen_string_literal: true

class User < ApplicationRecord
  belongs_to :employee, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :employee_id, presence: true
  validates :employee, presence: true, if: :employee_id

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
end
