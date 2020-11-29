# frozen_string_literal: true

# create -> self_assign

class AssignmentsController < ApplicationController
  load_and_authorize_resource :user, only: :index
  load_and_authorize_resource through: :user, class: 'Task', only: :index
  load_and_authorize_resource :task, only: %i[new create]
  before_action :load_and_authorize_task, only: %i[edit update]

  def index
    # TODO: add previously assigned thru progressions too
    @assignments = @assignments.filter_by(build_filters).page(params[:page])
  end

  def new
    authorize! :self_assign, @task
    @task_assignee = @task.task_assignees.build(assignee_id: current_user.id)
  end

  def create
    authorize! :self_assign, @task
    @task_assignee = @task.task_assignees.build(assignee_id: current_user.id)

    if @task_assignee.save
      @task.subscribe_user(current_user)
      redirect_to @task, notice: 'Task assignment was successfully updated.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @task.update(task_params)
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
