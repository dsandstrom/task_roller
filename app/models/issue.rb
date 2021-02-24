# frozen_string_literal: true

# FIXME: issue closure for invalid issue, not closed
# issue user destroyed, add closure, shows as open

class Issue < ApplicationRecord # rubocop:disable Metrics/ClassLength
  DEFAULT_ORDER = 'issues.updated_at desc'
  STATUS_OPTIONS = {
    open: { color: 'green' },
    being_worked_on: { color: 'yellow' },
    addressed: { color: 'red' },
    resolved: { color: 'blue' },
    duplicate: { color: 'purple' },
    closed: { color: 'red' }
  }.freeze

  belongs_to :user # reporter
  belongs_to :issue_type
  belongs_to :project
  has_many :tasks, -> { order(created_at: :asc) }, dependent: :nullify
  has_many :comments, class_name: 'IssueComment', foreign_key: :issue_id,
                      dependent: :destroy, inverse_of: :issue
  delegate :category, to: :project
  has_many :resolutions, dependent: :destroy
  has_one :source_connection, class_name: 'IssueConnection',
                              foreign_key: :source_id, dependent: :destroy,
                              inverse_of: :source
  # TODO: add better name
  has_one :duplicatee, through: :source_connection, class_name: 'Issue',
                       source: :target
  has_many :target_connections, class_name: 'IssueConnection',
                                foreign_key: :target_id, dependent: :destroy,
                                inverse_of: :target
  has_many :duplicates, through: :target_connections, class_name: 'Issue',
                        source: :source
  has_many :issue_subscriptions, dependent: :destroy, foreign_key: :issue_id
  has_many :subscribers, through: :issue_subscriptions, foreign_key: :user_id,
                         source: :user
  has_many :closures, class_name: 'IssueClosure'
  has_many :reopenings, class_name: 'IssueReopening'

  validates :summary, presence: true, length: { maximum: 200 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :user_id, presence: true
  validates :user, presence: true, if: :user_id
  validates :issue_type_id, presence: true
  validates :issue_type, presence: true, if: :issue_type_id
  validates :project_id, presence: true
  validates :project, presence: true, if: :project_id
  validates :status, inclusion: { in: STATUS_OPTIONS.keys.map(&:to_s) }

  after_create :set_opened_at

  # CLASS

  def self.all_non_closed
    where(closed: false)
  end

  def self.all_closed
    where(closed: true)
  end

  def self.all_open
    where(closed: false, status: 'open')
  end

  def self.all_being_worked_on
    where(closed: false, status: 'being_worked_on')
  end

  def self.all_addressed
    where(closed: true, status: 'addressed')
  end

  def self.all_resolved
    where(closed: true, status: 'resolved')
  end

  def self.filter_by(filters = {})
    filter_by_status(filters[:issue_status])
      .filter_by_type(filters[:issue_type_id])
      .filter_by_string(filters[:query])
      .order(build_order_param(filters[:order]))
      .distinct
  end

  def self.filter_by_status(status)
    return all unless status

    options = STATUS_OPTIONS.keys
    return all unless options.include?(status.to_sym)

    send("all_#{status}")
  end

  # TODO: search text in associated comments too (comments.body)
  def self.filter_by_string(query)
    return all if query.blank?

    where('issues.summary ILIKE :query OR issues.description ILIKE :query',
          query: "%#{query}%")
  end

  def self.filter_by_type(issue_type_id)
    return all if issue_type_id.blank?
    return none unless IssueType.find_by(id: issue_type_id)

    where(issue_type_id: issue_type_id)
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

  def self.all_visible
    joins(:project, project: :category)
      .where('projects.visible = :visible AND categories.visible = :visible',
             visible: true)
  end

  def self.all_invisible
    joins(:project, project: :category)
      .where('projects.visible = :visible OR categories.visible = :visible',
             visible: false)
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
    @open_ = !closed? if @open_.nil?
    @open_
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

  def unresolved?
    return @unresolved unless @unresolved.nil?

    @unresolved = open? && current_resolutions.none?
  end

  def close
    update closed: true
    update_status
  end

  def reopen
    update closed: false, opened_at: Time.now
    update_status
  end

  def subscribe_user(subscriber = nil)
    subscriber ||= user
    return unless subscriber

    issue_subscriptions.create(user_id: subscriber.id)
  end

  # TODO: use ActiveJob
  def subscribe_users
    subscribe_user
    category.issue_subscribers.each { |u| subscribe_user(u) }
    project.issue_subscribers.each { |u| subscribe_user(u) }
  end

  def approved_tasks
    @approved_tasks ||= tasks.all_approved
  end

  def addressed_at
    return if approved_tasks.none?

    @addressed_at ||=
      approved_tasks
      .select('tasks.id, MAX(reviews.updated_at) AS addressed_at')
      .group(:id).reorder(addressed_at: :desc).first&.addressed_at
  end

  # feed of closures, reopenings, duplicate, tasks, resolutions
  # TODO: add addressed_at (hardcoded on show right now)
  def history_feed
    @history_feed ||= build_history_feed
  end

  def update_status
    update_attribute :status, build_status
  end

  private

    def set_opened_at
      return if opened_at.present? || created_at.nil?

      update_column :opened_at, updated_at
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
    def build_status
      if closed?
        build_closed_status
      else
        build_open_status
      end
    end

    def build_open_status
      if open_tasks?
        'being_worked_on'
      else
        'open'
      end
    end

    def build_closed_status
      if resolution_approved?
        'resolved'
      elsif tasks_approved?
        'addressed'
      elsif source_connection?
        'duplicate'
      else
        'closed'
      end
    end

    def open_tasks?
      return @open_tasks_ unless @open_tasks_.nil?

      @open_tasks_ = open? && open_tasks.any?
    end

    # all tasks closed, any approved
    # no approved resolution, but can have an open resolution
    def tasks_approved?
      return @tasks_approved unless @tasks_approved.nil?

      @tasks_approved =
        !resolution_approved? && closed && open_tasks.none? &&
        tasks.any?(&:approved?)
    end

    # current resolution approved
    def resolution_approved?
      return @resolution_approved unless @resolution_approved.nil?

      @resolution_approved =
        if current_resolution
          current_resolution.approved?
        else
          false
        end
    end

    def source_connection?
      return @source_connection_ unless @source_connection_.nil?

      @source_connection_ = source_connection.present?
    end

    def build_history_feed
      feed = []
      [closures, reopenings, resolutions, tasks].each do |collection|
        feed << collection if collection.any?
      end
      feed << source_connection if source_connection
      feed.flatten.sort_by(&:created_at)
    end
end
