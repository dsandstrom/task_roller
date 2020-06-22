# frozen_string_literal: true

class TaskAssignmentsController < ApplicationController
  before_action :set_task, only: %i[show edit update destroy]

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to category_project_task_url(@category, @project, @task),
                  notice: 'Task assignment was successfully updated.'
    else
      render :edit
    end
  end

  private

    # TODO: authorize access
    def set_task
      @task = Task.find(params[:id])
      @project = @task.project
      @category = @project.category
    end

    def task_params
      params.require(:task).permit(assignee_ids: [])
    end
end
