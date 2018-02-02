# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

    def set_issue_type
      @issue_type = IssueType.find(params[:id])
    end

    def set_task_type
      @task_type = TaskType.find(params[:id])
    end
end
