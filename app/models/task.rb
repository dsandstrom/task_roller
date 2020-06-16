# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :user # reviewer
  belongs_to :task_type
  belongs_to :project
  belongs_to :issue, required: false
  has_many :task_assignees, dependent: :destroy
  has_many :assignees, through: :task_assignees
  has_many :comments, class_name: 'TaskComment', foreign_key: :roller_id,
                      dependent: :destroy, inverse_of: :task
  delegate :category, to: :project

  accepts_nested_attributes_for :assignees

  validates :summary, presence: true, length: { maximum: 200 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :user_id, presence: true
  validates :task_type_id, presence: true
  validates :project_id, presence: true

  # CLASS

  def self.all_open
    where(closed: false)
  end

  def self.all_closed
    where(closed: true)
  end

  # INSTANCE

  def description_html
    @description_html ||= (RollerMarkdown.new.render(description) || '')
  end

  def short_summary
    @short_summary ||= summary&.truncate(100)
  end

  def open?
    !closed?
  end
end
