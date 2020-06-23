# frozen_string_literal: true

class Task < ApplicationRecord
  DEFAULT_ORDER = 'tasks.updated_at desc'

  belongs_to :user # reviewer
  belongs_to :task_type
  belongs_to :project
  belongs_to :issue, required: false
  has_many :task_assignees, dependent: :destroy
  has_many :assignees, through: :task_assignees
  has_many :progressions, dependent: :destroy
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

  def self.filter(filters = {})
    parent = filters[:project] || filters[:category]
    return Task.none unless parent

    tasks = parent.tasks
    return Task.none unless tasks&.any?

    tasks.includes(task_assignees: :assignee, issue: :user)
         .apply_filters(filters)
         .order(build_order_param(filters[:order]))
  end

  # used by .filter
  def self.apply_filters(filters)
    tasks = all
    tasks = tasks.filter_by_status(filters[:status])
    tasks = tasks.filter_by_user_id(filters[:reviewer])
    tasks = tasks.filter_by_assigned_id(filters[:assigned])
    tasks
  end

  # used by .filter
  def self.filter_by_status(status)
    if status == 'open'
      all_open
    elsif status == 'closed'
      all_closed
    else
      all
    end
  end

  # used by .filter
  def self.filter_by_user_id(user_id)
    return all if user_id.blank?

    where(user_id: user_id)
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
    @short_summary ||= summary&.truncate(100)
  end

  def heading
    @heading ||= ("Task: #{short_summary}" if short_summary.present?)
  end

  def open?
    !closed?
  end

  # TODO: add options to categories/projects on which users are assignable
  def assignable
    @assignable ||= User.assignable_employees
  end

  # users from progressions that aren't current assignees
  def assigned
    @assigned ||= build_assigned
  end

  # open
  # unassigned => assign
  # assigned => start work
  # being worked on => put in for review
  # in review => approve
  #   * approved
  # in review => disapprove
  #   * assigned
  # closed

  def status_state
    @status_state ||=
      (self.status ||= assignees.any? ? 'assigned' : 'unassigned')
  end

  private

    def build_assigned
      users = User.joins(:progressions).where('progressions.task_id = ?', id)
      if assignee_ids.any?
        users = users.where('users.id NOT IN (?)', assignee_ids)
      end
      users.distinct
    end
end
