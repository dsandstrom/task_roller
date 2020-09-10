# frozen_string_literal: true

# TODO: add CustomField/Value/Option for more issue/task attrs
# TODO: add visible boolean (for moderation)
# TODO: add closed statuses (duplicate, rejected, won't fix, addressed,
# deferred, invalid)
# Deferred/to-do: We will not fix this immediately, but will consider fixing
# this in future
# Won't Fix: The issue cannot be fixed
# Invalid: This is not an issue, but was interpreted wrongly as one

class Issue < ApplicationRecord # rubocop:disable Metrics/ClassLength
  DEFAULT_ORDER = 'issues.updated_at desc'

  belongs_to :user # reporter
  belongs_to :issue_type
  belongs_to :project
  has_many :tasks, dependent: :nullify
  has_many :comments, class_name: 'IssueComment', foreign_key: :roller_id,
                      dependent: :destroy, inverse_of: :issue
  delegate :category, to: :project
  has_many :resolutions, dependent: :destroy

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

  def self.all_non_closed
    where(closed: false)
  end

  def self.all_closed
    where(closed: true)
  end

  # no tasks
  def self.all_open
    all_non_closed.where(tasks_count: 0)
  end

  # with open tasks
  def self.all_being_worked_on
    all_non_closed.where.not(open_tasks_count: 0)
  end

  # all tasks closed, any approved
  # no approved resolution, but can have an open resolution
  # TODO: resolution counter cache?
  def self.all_addressed
    resolutions_query =
      'issues.id NOT IN (SELECT DISTINCT(issue_id) FROM resolutions WHERE ' \
      'resolutions.approved = ? AND resolutions.created_at > issues.opened_at)'
    all_closed.joins(tasks: :reviews).left_outer_joins(:resolutions)
              .where('reviews.approved = ?', true).where(open_tasks_count: 0)
              .where(resolutions_query, true)
  end

  # current resolution approved
  def self.all_resolved
    query =
      'resolutions.approved = ? AND resolutions.created_at > issues.opened_at'
    all_closed.joins(:resolutions).where(query, true)
  end

  # no current approved resolution
  # use all_addressed
  def self.all_unresolved
    resolutions_query =
      'issues.id NOT IN (SELECT DISTINCT(issue_id) FROM resolutions WHERE ' \
      'resolutions.approved = ? AND resolutions.created_at > issues.opened_at)'
    all_non_closed.where(resolutions_query, true)
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

  # TODO: allow filtering by multiple statuses
  def self.filter_by_status(status)
    options = %w[open closed being_worked_on addressed resolved]
    return all unless options.include?(status)

    send("all_#{status}")
  end

  # used by .filter
  def self.filter_by_user_id(user_id)
    return all if user_id.blank?

    where(user_id: user_id)
  end

  # used by .filter
  # TODO: change to working_on
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
    @short_summary ||= summary&.truncate(70)
  end

  def heading
    @heading ||= ("Issue: #{short_summary}" if short_summary.present?)
  end

  def open?
    !closed?
  end

  # TODO: add open_tasks_count counter cache
  def open_tasks
    @open_tasks ||= tasks.all_open
  end

  # TODO: add closed_tasks_count counter cache
  def closed_tasks
    @closed_tasks ||= tasks.all_closed
  end

  def current_tasks
    if @current_tasks.instance_of?(ActiveRecord::AssociationRelation)
      return @current_tasks
    end

    @current_tasks = tasks.where('tasks.created_at > ?', opened_at)
  end

  def current_resolutions
    if @current_resolutions.instance_of?(ActiveRecord::AssociationRelation)
      return @current_resolutions
    end

    @current_resolutions =
      resolutions.where('resolutions.created_at > ?', opened_at)
  end

  def current_resolution
    @current_resolution ||= current_resolutions.order(created_at: :desc).first
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
    return @working_on unless @working_on.nil?

    @working_on = open? && open_tasks.any?
  end

  def addressed?
    return @addressed unless @addressed.nil?

    @addressed =
      !resolved? && closed && open_tasks.none? &&
      tasks.any?(&:approved?)
  end

  def resolved?
    return @resolved unless @resolved.nil?

    @resolved =
      if current_resolution
        current_resolution.approved?
      else
        false
      end
  end

  def unresolved?
    return @unresolved unless @unresolved.nil?

    @unresolved = open? && current_resolutions.none?
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
      if resolved?
        'resolved'
      elsif addressed?
        'addressed'
      else
        'closed'
      end
    end
end
