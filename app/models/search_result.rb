# frozen_string_literal: true

class SearchResult < ApplicationRecord
  DEFAULT_ORDER = 'search_results.updated_at desc'

  self.primary_key = :id

  belongs_to :user
  belongs_to :project
  delegate :category, to: :project
  belongs_to :issue
  # TODO: if issue
  belongs_to :task_type, foreign_key: :type_id
  # TODO: if task
  belongs_to :issue_type, foreign_key: :type_id
  has_many :task_assignees, foreign_key: :task_id
  has_many :assignees, through: :task_assignees

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
    results.order(build_order_param(filters[:order])).distinct
  end

  def self.filter_by_string(query)
    return all if query.blank?

    where('summary ILIKE :query OR description ILIKE :query',
          query: "%#{query}%")
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

    "#{column}_at #{direction}"
  end

  def self.split_id(query)
    return unless query

    number = query[/\d+/]
    query = query.sub(/(issue|task)?\s?[#-]?\d+\s?/i, '') if number
    [number&.to_i, query]
  end

  private_class_method def self.filter_by_id(query)
    return all if query.blank?

    where('id = :id OR issue_id = :id', id: query.to_i)
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
