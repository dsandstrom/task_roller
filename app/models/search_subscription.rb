class SearchSubscription < ApplicationRecord
  belongs_to :user
  belongs_to :source_user, class_name: 'User', optional: true
  belongs_to :category, optional: true
  belongs_to :project, optional: true
  belongs_to :issue_type, optional: true
  belongs_to :task_type, optional: true

  validates :term, length: { maximum: 50 }
  validate :any_search_parameter
  validate :either_include_issues_or_tasks

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

    def either_include_issues_or_tasks
      return if include_issues || include_tasks

      errors.add(:base, 'must include issues or tasks')
    end
end
