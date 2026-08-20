class ApplicationController < ActionController::Base
  FILTER_OPTIONS = %i[issue_status task_status type issue_type_id task_type_id
                      project_ids order query].freeze

  protect_from_forgery with: :exception

  before_action :authenticate_user!
  check_authorization unless: :devise_controller?

  rescue_from CanCan::AccessDenied, with: :user_not_authorized

  private

    def set_issue_type
      @issue_type = authorize(IssueType.find(params.expect(:id)))
    end

    def set_task_type
      @task_type = authorize(TaskType.find(params.expect(:id)))
    end

    def set_category
      @category = Category.find(params.expect(:category_id))
    end

    def set_project
      return unless @category && params.expect(:project_id)

      @project = @category.projects.find(params.expect(:project_id))
    end

    def build_filters
      filters = {}
      FILTER_OPTIONS.each do |param|
        filters[param] = params[param]
      end
      filters[:issue_type_id] = nil if filters[:issue_type_id] == 'all'
      filters[:task_type_id] = nil if filters[:task_type_id] == 'all'
      if filters[:query].present?
        filters[:query] = filters[:query].truncate(80, omission: '')
      end
      filters
    end

    def user_not_authorized
      respond_to do |format|
        format.json { head :forbidden, content_type: 'text/html' }
        format.html { redirect_to main_app.unauthorized_url }
        format.turbo_stream { head :forbidden, content_type: 'text/html' }
      end
    end

    def current_user_id
      @current_user_id ||= current_user&.id
    end

    def order_by
      @order_by ||= params[:order].blank? || params[:order] == 'updated,desc'
    end

    def build_assignee_options
      User.assignable_employees([current_user])
          .group_by(&:employee_type)
          .map do |type, type_employees|
        [type.pluralize, type_employees.map { |u| [u.name_and_email, u.id] }]
      end
    end

    def build_issue_options
      options =
        @task.project.issues.all_open.map do |issue|
          [issue.id_and_summary, issue.id]
        end
      if @task.issue
        options = [[@task.issue.id_and_summary, @task.issue_id]] | options
      end
      options
    end

    def build_project_options
      Category.all_visible.accessible_by(current_ability).map do |category|
        projects = category.projects.all_visible
                           .accessible_by(current_ability).map do |project|
          [project.name, project.id]
        end

        [category.name, projects] if projects.any?
      end.compact
    end
end
