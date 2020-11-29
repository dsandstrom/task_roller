# frozen_string_literal: true

class TaskAssigneesController < ApplicationController
  load_and_authorize_resource :task
  load_and_authorize_resource through: :task

  def new
    @task_assignee.assignee_id = current_user.id
  end

  def create
    @task_assignee.assignee_id = current_user.id

    if @task_assignee.save
      @task.subscribe_user(current_user)
      redirect_to @task, notice: 'Task assignment was successfully created.'
    else
      render :new
    end
  end
end
