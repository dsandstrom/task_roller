# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :user # reviewer
  belongs_to :task_type
  belongs_to :project
  belongs_to :issue, required: false
  delegate :category, to: :project

  validates :summary, presence: true, length: { maximum: 200 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :user_id, presence: true
  validates :task_type_id, presence: true
  validates :project_id, presence: true
end
