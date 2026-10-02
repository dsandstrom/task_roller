class SearchSubscription < ApplicationRecord
  belongs_to :user
  belongs_to :source_user, class_name: 'User', optional: true
  belongs_to :category, optional: true
  belongs_to :project, optional: true
  belongs_to :issue_type, optional: true
  belongs_to :task_type, optional: true

  validates :term, length: { maximum: 50 }
  validates :user_id,
            uniqueness: { scope: %i[include_issues include_tasks term
                                    source_user_id category_id project_id
                                    issue_status task_status issue_type_id
                                    task_type_id] }

  validate :any_search_parameter
  validate :either_include_issues_or_tasks
  validate :either_issue_attrs_or_task_attrs

  def toggle
    update(active: !active)
  end

  def search_results
    SearchResult.filter_by(search_result_attrs).all_visible
  end

  def title
    @title ||= build_title
  end

  def filter_params
    SearchFiltersConverter.convert_attrs_to_filter_params(self)
  end

  private

    def any_search_parameter
      return if term.present? || type_present? || status_present? ||
                source_user_id.present? || category_id.present? ||
                project_id.present?

      errors.add(:base, 'must have at least one search parameter')
    end

    def type_present?
      (include_issues && issue_type_id.present?) ||
        (include_tasks && task_type_id.present?)
    end

    def status_present?
      issue_status.present? || task_status.present?
    end

    def either_issue_attrs_or_task_attrs
      return if not_mixing_issues_with_task_parameters? &&
                not_mixing_tasks_with_issue_parameters?

      unless include_issues && include_tasks
        return if not_mixing_issues_with_task_parameters?
        return if not_mixing_tasks_with_issue_parameters?
      end

      errors.add(:base, 'must not mix issue and task parameters')
    end

    def not_mixing_issues_with_task_parameters?
      include_issues && task_type_id.blank? && task_status.blank?
    end

    def not_mixing_tasks_with_issue_parameters?
      include_tasks && issue_type_id.blank? && issue_status.blank?
    end

    def either_include_issues_or_tasks
      return if include_issues || include_tasks

      errors.add(:base, 'must include issues or tasks')
    end

    def add_project_ids_attr(attrs)
      if category.present?
        attrs[:project_ids] = category.projects.all_visible.map(&:id)
      elsif project.present?
        attrs[:project_ids] = project.visible? ? [project_id] : []
      end

      attrs
    end

    def add_class_name_attr(attrs)
      attrs[:class_name] =
        if include_issues && !include_tasks
          'Issue'
        elsif include_tasks && !include_issues
          'Task'
        end
      attrs
    end

    def search_result_attrs
      attrs = add_class_name_attr(add_project_ids_attr(filter_params))

      attrs[:user_id] = source_user_id if source_user.present?
      attrs[:type_id] = issue_type_id || task_type_id

      attrs
    end

    def build_title
      text = type_title_part(issues_or_tasks_title_part)
      if source_user
        text += " from #{source_user.name}"
      elsif category || project
        text += ' from '
        text += category_project_title_part
      end
      text = status_title_part(text)
      text += " that match \"#{term}\"" if term.present?
      text
    end

    def category_project_title_part
      if category
        category.name
      else
        project.name
      end
    end

    def type_title_part(text)
      return text unless issue_type || task_type

      if issue_type
        "#{issue_type.name} #{text}"
      else
        "#{task_type.name} #{text}"
      end
    end

    def issues_or_tasks_title_part
      if include_issues && include_tasks
        'Issues and Tasks'
      elsif include_issues
        'Issues'
      else
        'Tasks'
      end
    end

    def status_title_part(text)
      return text unless issue_status.present? || task_status.present?

      text += ' with '
      text +=
        if issue_status.present?
          issue_status.titleize
        else
          task_status.titleize
        end

      "#{text} status"
    end
end
