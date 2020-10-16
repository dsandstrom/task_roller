# frozen_string_literal: true

class TaskAssignmentsController < ApplicationController
  before_action :set_task

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

    def set_task
      @task = authorize(Task.find(params[:id]), :assign?)

      @project = @task.project
      @category = @project.category
    end

    def task_params
      params.require(:task).permit(assignee_ids: [])
    end
end
