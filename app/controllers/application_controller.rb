# frozen_string_literal: true

# TODO: test redirect if not logged in
# TODO: test redirect to login if non-employee
# TODO: move `before_action authenticate` here instead of autoloading

class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception

  before_action :authenticate

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

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
      redirect_to :unauthorized
    end
end
