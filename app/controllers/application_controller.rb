# frozen_string_literal: true

# TODO: test redirect if not logged in
# TODO: test redirect to login if non-employee

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  check_authorization unless: :devise_controller?

  rescue_from CanCan::AccessDenied, with: :user_not_authorized

  private

    def set_issue_type
      @issue_type = authorize(IssueType.find(params[:id]))
    end

    def set_task_type
      @task_type = authorize(TaskType.find(params[:id]))
    end

    def set_category
      @category = Category.find(params[:category_id])
    end

    def set_project
      return unless @category && params[:project_id]

      @project = @category.projects.find(params[:project_id])
    end

    def build_filters
      filters = {}
      %i[status order].each do |param|
        filters[param] = params[param]
      end
      filters
    end

    def user_not_authorized
      respond_to do |format|
        format.json { head :forbidden, content_type: 'text/html' }
        format.html { redirect_to main_app.unauthorized_url }
        format.js   { head :forbidden, content_type: 'text/html' }
      end
    end
end
