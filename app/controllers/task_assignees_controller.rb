# frozen_string_literal: true

class TaskAssigneesController < ApplicationController
  load_and_authorize_resource :task
  load_resource through: :task

  def new
    authorize! :self_assign, @task
    @task_assignee.assignee_id = current_user.id
  end

  def create
    authorize! :self_assign, @task
    @task_assignee.assignee_id = current_user.id

    if @task_assignee.save
      @task.subscribe_user(current_user)
      redirect_to @task, notice: 'Task assignment was successfully updated.'
    else
      render :new
    end
  end
end
