# frozen_string_literal: true

# TODO: rename to AssignmentsController?
class TaskAssignmentsController < ApplicationController
  load_and_authorize_resource :user, only: :index
  before_action :set_task, except: :index

  def index
    authorize! :read, Task

    @tasks = @user.assignments.filter_by(build_filters).page(params[:page])
  end

  def edit; end

  def update
    if @task.update(task_params)
      redirect_to @task, notice: 'Task assignment was successfully updated.'
    else
      render :edit
    end
  end

  private

    def set_task
      @task = Task.find(params[:id])
      authorize! :assign, @task
    end

    def task_params
      params.require(:task).permit(assignee_ids: [])
    end
end
