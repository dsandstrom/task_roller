# frozen_string_literal: true

# TODO: rename to AssignmentsController?
class TaskAssignmentsController < ApplicationController
  before_action :set_task, except: :index

  def index
    authorize Task
    @user = User.find(params[:user_id])
    @tasks = @user.assignments.filter_by(build_filters).page(params[:page])
  end

  def edit
  end

  def update
    if @task.update(task_params)
      redirect_to task_url(@task),
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

    def build_filters
      filters = {}
      %i[status order].each do |param|
        filters[param] = params[param]
      end
      filters
    end
end
