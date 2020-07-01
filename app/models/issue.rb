# frozen_string_literal: true

# TODO: add CustomField/Value/Option for more issue/task attrs
# TODO: add visible boolean (for moderation)
# TODO: add closed statuses (duplicate, rejected, won't fix, addressed,
# deferred, invalid)
# Deferred/to-do: We will not fix this immediately, but will consider fixing
# this in future
# Won't Fix: The issue cannot be fixed
# Invalid: This is not an issue, but was interpreted wrongly as one
# TODO: add resolution approval - allow user to approve issue is resolved
# not sure if it should hold it up being closed

class Issue < ApplicationRecord # rubocop:disable Metrics/ClassLength
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
  validates :user, presence: true, if: :user_id
  validates :issue_type_id, presence: true
  validates :issue_type, presence: true, if: :issue_type_id
  validates :project_id, presence: true
  validates :project, presence: true, if: :project_id

  after_create :set_opened_at

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

  # - closed
  #   - all tasks closed, any approved = 'addressed'
  #   - resolution approval open = 'addressed'
  #   - resolution approval rejected = 'unresolved'
  #   - resolution approved -> 'resolved'
  #   - all tasks closed but none approved = invalid, won't fix
  #   - no tasks = invalid or won't fix
  # - open
  #   - no tasks or no approved tasks = 'open'
  #   - tasks open = 'being worked on'
  def status
    @status ||=
      if closed?
        closed_status
      else
        open_status
      end
  end

  def working_on?
    @working_on ||= open? && open_tasks.any?
  end

  def addressed?
    @addressed ||= open_tasks.none? && tasks.any?(&:approved?)
  end

  def close
    update closed: true
  end

  def open
    update closed: false, opened_at: Time.now
  end

  private

    def set_opened_at
      return if opened_at.present? || created_at.nil?

      update_column :opened_at, updated_at
    end

    def open_status
      if working_on?
        'being worked on'
      else
        'open'
      end
    end

    def closed_status
      if addressed?
        'addressed'
      else
        'closed'
      end
    end
end
