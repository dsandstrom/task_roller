# frozen_string_literal: true

class Task < ApplicationRecord # rubocop:disable Metrics/ClassLength
  DEFAULT_ORDER = 'tasks.updated_at desc'

  belongs_to :user # reviewer
  belongs_to :task_type
  belongs_to :project
  belongs_to :issue, required: false
  has_many :task_assignees, dependent: :destroy
  has_many :assignees, through: :task_assignees,
                       before_remove: :finish_assignee_progressions
  has_many :progressions, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :comments, class_name: 'TaskComment', foreign_key: :roller_id,
                      dependent: :destroy, inverse_of: :task
  delegate :category, to: :project

  accepts_nested_attributes_for :assignees

  validates :summary, presence: true, length: { maximum: 200 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :user_id, presence: true
  validates :user, presence: true, if: :user_id
  validates :task_type_id, presence: true
  validates :task_type, presence: true, if: :task_type_id
  validates :project_id, presence: true
  validates :project, presence: true, if: :project_id

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

  # not waiting for approval or already approved
  def ready_for_review?
    @ready_for_review ||=
      if closed?
        false
      else
        reviews.pending.or(reviews.approved).none?
      end
  end

  # TODO: add options to categories/projects on which users are assignable
  def assignable
    @assignable ||= User.assignable_employees
  end

  def reviewable
    @reviewable ||= User.reviewers
  end

  # users from progressions that aren't current assignees
  def assigned
    @assigned ||= build_assigned
  end

  def user_form_options
    @user_form_options ||=
      %w[Admin Reviewer].map do |type|
        [type, User.employees(type).map { |u| [u.name_and_email, u.id] }]
      end
  end

  # - closed
  # - open
  #   - reviews open = 'in review'
  #   - progressions unfinished = 'in progress'
  #   - any assignees = 'assigned'
  #   - unassigned = 'open'
  def status
    @status ||= build_status
  end

  def finish
    progressions&.unfinished&.each(&:finish)
    true
  end

  def close
    finish
    update closed: true
  end

  # TODO: remove approved reviews or make them outdated
  # TODO: if 'in progress' move disapproved reviews to history
  # TODO: move reviews to history
  def open
    update closed: false
  end

  def current_review
    @current_review ||= reviews.order(created_at: :desc).first
  end

  def in_review?
    @in_review ||= open? && reviews.pending.any?
  end

  def in_progress?
    @in_progress ||=
      if in_review?
        false
      else
        open? && progressions.unfinished.any?
      end
  end

  # rubocop:disable Naming/MemoizedInstanceVariableName
  def assigned?
    @assigned_ ||=
      if in_review? || in_progress?
        false
      else
        open? && assignees.any?
      end
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName

  private

    def build_assigned
      users = User.includes(:progressions).where('progressions.task_id = ?', id)
      if open? && assignee_ids.any?
        users = users.where('users.id NOT IN (?)', assignee_ids)
      end
      users.order('progressions.created_at desc')
    end

    def build_status
      return 'closed' if closed?

      if in_review?
        'in review'
      elsif in_progress?
        'in progress'
      elsif assigned?
        'assigned'
      else
        'open'
      end
    end

    def finish_assignee_progressions(assignee)
      assignee.finish_progressions
    end
end
