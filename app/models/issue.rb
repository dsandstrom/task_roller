# frozen_string_literal: true

# TODO: add CustomField/Value/Option for more issue/task attrs
# TODO: add visible boolean (for moderation)
# TODO: add closed statuses (duplicate, rejected/invalid)
# Deferred/to-do: We will not fix this immediately, but will consider fixing
# this in future
# Invalid: This is not an issue, but was interpreted wrongly as one
# when closing issue, add dialog that confirms and allows adding a comment
# TODO: allow subscribing/following issues/tasks
# TODO: add last_commented_at, max(issue_comments.created_at) show in partial
# the thing is, only comments by other users matter, not static
# TODO: allow reviewer+ to change project (any category)

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
  has_one :source_issue_connection, class_name: 'IssueConnection',
                                    foreign_key: :source_id,
                                    dependent: :destroy, inverse_of: :source
  # TODO: add better name
  has_one :duplicatee, through: :source_issue_connection, class_name: 'Issue',
                       source: :target
  has_many :target_issue_connections, class_name: 'IssueConnection',
                                      foreign_key: :target_id,
                                      dependent: :destroy, inverse_of: :target
  has_many :duplicates, through: :target_issue_connections, class_name: 'Issue',
                        source: :source
  has_many :issue_subscriptions, dependent: :destroy, foreign_key: :issue_id
  has_many :subscribers, through: :issue_subscriptions, foreign_key: :user_id,
                         class_name: 'User'

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

  def self.filter_by(filters = {})
    filter_by_status(filters[:status])
      .order(build_order_param(filters[:order]))
      .distinct
  end

  # TODO: allow filtering by multiple statuses
  def self.filter_by_status(status)
    options = %w[open closed being_worked_on addressed resolved]
    return all unless options.include?(status)

    send("all_#{status}")
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

  def id_and_summary
    @id_and_summary ||= ("##{id} - #{short_summary}" if id && summary.present?)
  end

  def heading
    @heading ||= ("Issue \##{id}: #{short_summary}" if id && summary.present?)
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

  def subscribe_user(subscriber = nil)
    subscriber ||= user
    return unless subscriber

    issue_subscriptions.create(user_id: subscriber.id)
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
