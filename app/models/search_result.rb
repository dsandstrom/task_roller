# frozen_string_literal: true

class SearchResult < ApplicationRecord
  DEFAULT_ORDER = 'search_results.updated_at desc'

  self.primary_key = :id

  belongs_to :user
  belongs_to :project
  delegate :category, to: :project
  belongs_to :issue
  # TODO: if issue
  belongs_to :task_type, foreign_key: :type_id, optional: true,
                         inverse_of: :search_results
  # TODO: if task
  belongs_to :issue_type, foreign_key: :type_id, optional: true,
                          inverse_of: :search_results
  has_many :task_assignees, foreign_key: :task_id, dependent: nil,
                            inverse_of: :search_results
  has_many :assignees, through: :task_assignees
  has_many :tasks, foreign_key: :issue_id, dependent: nil,
                   inverse_of: :search_result

  # CLASS

  # TODO: find categories & projects
  # TODO: search issue's tasks and task's issues
  # TODO: if "issue-123", search issues
  def self.filter_by(filters = {})
    project_ids = filters[:project_ids]
    return none if project_ids&.none?

    id, query = split_id(filters[:query])
    results = filter_by_id(id)
    results = results.filter_by_string(query)
                     .filter_by_projects(filters[:project_ids])
    results.order(build_order_param(filters[:order]))
  end

  def self.filter_by_string(query)
    return all if query.blank?

    filters = %w[summary description].map do |column|
      "search_results.#{column} ILIKE :query"
    end.join(' OR ')
    where(filters, query: "%#{query}%")
  end

  def self.filter_by_projects(project_ids)
    return none if project_ids == []
    return all if project_ids.blank?

    where(project_id: project_ids)
  end

  def self.build_order_param(order)
    return DEFAULT_ORDER if order.blank?

    column, direction = order.split(',')
    return DEFAULT_ORDER unless direction &&
                                %w[created updated].include?(column) &&
                                %w[asc desc].include?(direction)

    "search_results.#{column}_at #{direction}"
  end

  def self.split_id(query)
    return unless query

    number = query[/\d+/]
    query = query.sub(/(issue|task)?\s?[#-]?\d+\s?/i, '') if number
    [number&.to_i, query]
  end

  def self.all_visible
    joins(:project, project: :category)
      .where('projects.visible = :visible AND categories.visible = :visible',
             visible: true)
  end

  def self.with_notifications(user, order_by: false)
    attrs = %w[id project_id user_id issue_id class_name created_at updated_at
               summary description status type_id]
    preloads = [:project, :user, :issue, :assignees, { project: :category }]
    search_results = joins(user.notifications_query).select(attrs).group(attrs)
                                                    .preload(preloads)
    return search_results unless order_by

    search_results.order('COUNT(issue_notifications.id) DESC')
                  .order('COUNT(task_notifications.id) DESC')
  end

  private_class_method def self.filter_by_id(query)
    return all if query.blank?

    filters = %w[id issue_id].map do |column|
      "search_results.#{column} = :id"
    end.join(' OR ')
    where(filters, id: query.to_i)
  end

  # INSTANCE

  def issue?
    class_name == 'Issue'
  end

  def task?
    class_name == 'Task'
  end

  def heading
    @heading ||=
      ("#{class_name} \##{id}: #{short_summary}" if id && summary.present?)
  end

  def short_summary
    @short_summary ||= summary&.truncate(70)
  end
end
