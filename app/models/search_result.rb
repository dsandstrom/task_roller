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
  def self.filter_by(filters = {})
    id, query = split_id(filters[:query])
    # TODO: if "issue-123", search issues
    query = query.gsub(/(issue|task)[\s\-]?/, '') if query
    results = filter_by_id(id)
    results = results.filter_by_string(query)

    results.order(build_order_param(filters[:order])).distinct
  end

  def self.filter_by_id(query)
    return all if query.blank?

    where(id: query.to_i)
  end

  def self.filter_by_string(query)
    return all if query.blank?

    where('summary ILIKE :query OR description ILIKE :query',
          query: "%#{query}%")
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
    query = query.sub(/\s?\d+\s?/, '') if number
    [number, query]
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
