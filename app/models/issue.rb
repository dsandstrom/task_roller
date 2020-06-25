# frozen_string_literal: true

# TODO: add CustomField/Value/Option for more issue/task attrs
# TODO: add visible boolean (for moderation)

class Issue < ApplicationRecord
  DEFAULT_ORDER = 'issues.updated_at desc'

  belongs_to :user # reporter
  belongs_to :issue_type
  belongs_to :project
  has_many :tasks, dependent: :nullify
  has_many :comments, class_name: 'IssueComment', foreign_key: :roller_id,
                      dependent: :destroy, inverse_of: :issue
  delegate :category, to: :project

  validates :summary, presence: true, length: { maximum: 200 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :user_id, presence: true
  validates :user, presence: true
  validates :issue_type_id, presence: true
  validates :issue_type, presence: true
  validates :project_id, presence: true
  validates :project, presence: true

  # CLASS

  def self.all_open
    where(closed: false)
  end

  def self.all_closed
    where(closed: true)
  end

  def self.with_open_task
    left_outer_joins(:tasks).where('tasks.closed = ?', false).distinct
  end

  def self.without_open_task
    left_outer_joins(:tasks).where('tasks.closed = ? OR tasks.id IS NULL', true)
  end

  def self.filter(filters = {})
    parent = filters[:project] || filters[:category]
    return Issue.none unless parent

    issues = parent.issues
    return Issue.none unless issues&.any?

    issues = issues.apply_filters(filters)
    issues.order(build_order_param(filters[:order]))
  end

  # used by .filter
  def self.apply_filters(filters)
    issues = all
    issues = issues.filter_by_status(filters[:status])
    issues = issues.filter_by_user_id(filters[:reporter])
    issues = issues.filter_by_open_tasks(filters[:open_tasks])
    issues
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
  def self.filter_by_open_tasks(count)
    return all if count.blank?

    if count.to_i.positive?
      with_open_task
    else
      without_open_task
    end
  end

  # used by .filter
  def self.build_order_param(order)
    return DEFAULT_ORDER if order.blank?

    column, direction = order.split(',')
    return DEFAULT_ORDER unless direction &&
                                %w[created updated].include?(column) &&
                                %w[asc desc].include?(direction)

    "issues.#{column}_at #{direction}"
  end

  # INSTANCE

  def description_html
    @description_html ||= (RollerMarkdown.new.render(description) || '')
  end

  def short_summary
    @short_summary ||= summary&.truncate(100)
  end

  def heading
    @heading ||= ("Issue: #{short_summary}" if short_summary.present?)
  end

  def open?
    !closed?
  end

  def open_tasks
    @open_tasks ||= tasks.all_open
  end

  def closed_tasks
    @closed_tasks ||= tasks.all_closed
  end
end
