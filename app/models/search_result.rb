# frozen_string_literal: true

class SearchResult < ApplicationRecord
  include Filter

  DEFAULT_ORDER = 'search_results.updated_at desc'

  self.primary_key = :id

  belongs_to :user
  belongs_to :project
  delegate :category, to: :project
  belongs_to :issue
  belongs_to :task_type, foreign_key: :type_id, optional: true,
                         inverse_of: :search_results
  belongs_to :issue_type, foreign_key: :type_id, optional: true,
                          inverse_of: :search_results
  has_many :task_assignees, foreign_key: :task_id, dependent: nil,
                            inverse_of: :search_result
  has_many :assignees, through: :task_assignees
  has_many :tasks, foreign_key: :issue_id, dependent: nil,
                   inverse_of: :search_result

  # CLASS

  def self.filter_by(filters = {})
    project_ids = filters[:project_ids]
    return none if project_ids&.none?

    apply_filters(normalize_filters(filters)).order(
      build_order_param('search_results', DEFAULT_ORDER, filters[:order])
    )
  end

  def self.all_visible
    joins(:project, project: :category)
      .where('projects.visible = :visible AND categories.visible = :visible',
             visible: true)
  end

  def self.with_notifications(user, order_by: false)
    attrs = %w[id project_id user_id issue_id class_name created_at updated_at
               summary description status type_id priority_level]
    preloads = [:project, :user, :issue, :assignees, { project: :category }]
    search_results = joins(user.notifications_query).select(attrs).group(attrs)
                                                    .preload(preloads)
    return search_results unless order_by

    search_results.order('COUNT(issue_notifications.id) DESC')
                  .order('COUNT(task_notifications.id) DESC')
  end

  # NOTE: can't private because filter_by_id returns ActiveRecord::Relation
  def self.filter_by_projects(project_ids)
    return none if project_ids == []
    return all if project_ids.blank?

    where(project_id: project_ids)
  end

  def self.filter_by_user(user_id)
    return all if user_id.blank?

    where(user_id: user_id)
  end

  def self.filter_by_class_name(class_name)
    return all unless class_name&.in?(%w[Issue Task])

    where(class_name: class_name)
  end

  def self.filter_by_status(issue_status, task_status)
    return all if issue_status.blank? && task_status.blank?

    if issue_status.present?
      where(status: issue_status)
    else
      where(status: task_status)
    end
  end

  def self.filter_by_type(type_id)
    return all if type_id.blank?

    where(type_id: type_id)
  end

  private_class_method def self.filter_by_id(query)
    return all if query.blank?

    filters = %w[id issue_id].map do |column|
      "search_results.#{column} = :id"
    end.join(' OR ')
    where(filters, id: query.to_i)
  end

  private_class_method def self.apply_filters(filters)
    id, query = split_id(filters[:query])

    filter_by_id(id)
      .filter_by_string('search_results', query)
      .filter_by_projects(filters[:project_ids])
      .filter_by_user(filters[:user_id])
      .filter_by_class_name(filters[:class_name])
      .filter_by_status(filters[:issue_status], filters[:task_status])
      .filter_by_type(filters[:type_id])
  end

  private_class_method def self.normalize_filters(filters)
    %i[issue_status task_status type_id].each do |key|
      filters[key] = nil if filters[key] == 'all'
    end

    if filters[:type] == 'all'
      %i[issue_status task_status issue_type_id task_type_id].each do |key|
        filters[key] = nil
      end
    end

    filters
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
      ("#{class_name} ##{id}: #{short_summary}" if id && summary.present?)
  end

  def short_summary
    @short_summary ||= summary&.truncate(70)
  end
end
