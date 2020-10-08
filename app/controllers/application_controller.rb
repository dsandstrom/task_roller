# frozen_string_literal: true

# TODO: test redirect if not logged in
# TODO: test redirect to login if non-employee

class ApplicationController < ActionController::Base
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protect_from_forgery with: :exception

  private

    def set_issue_type
      @issue_type = IssueType.find(params[:id])
      authorize @issue_type
    end

    def set_task_type
      @task_type = TaskType.find(params[:id])
      authorize @task_type
    end

    def set_category
      @category = Category.find(params[:category_id])
    end

    def set_project
      return unless @category && params[:project_id]

      @project = @category.projects.find(params[:project_id])
    end

    def user_not_authorized
      redirect_to :unauthorized
    end
end
