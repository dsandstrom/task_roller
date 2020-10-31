# frozen_string_literal: true

class RollerTypesController < ApplicationController
  def index
    authorize! :read, RollerType

    @issue_types = IssueType.all
    @task_types = TaskType.all
  end
end
