# frozen_string_literal: true

class AssignmentsController < ApplicationController
  load_and_authorize_resource :user, only: :index
  load_and_authorize_resource through: :user, class: 'Task', only: :index
  before_action :load_and_authorize_task, only: %i[edit update]

  def index
    @assignments = @assignments.all_visible.accessible_by(current_ability)
                               .filter_by(build_filters).page(params[:page])
  end

  def edit; end

  def update
    if @task.update(task_params)
      @task.update_status
      @task.subscribe_assignees
      redirect_to @task, notice: 'Task assignment was successfully updated.'
    else
      render :edit
    end
  end

  private

    def load_and_authorize_task
      @task = Task.find(params[:id])
      authorize! :assign, @task
    end

    def task_params
      params.require(:task).permit(assignee_ids: [])
    end
end
