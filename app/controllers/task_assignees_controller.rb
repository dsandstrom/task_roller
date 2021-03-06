# frozen_string_literal: true

class TaskAssigneesController < ApplicationController
  load_and_authorize_resource :task
  load_and_authorize_resource through: :task

  def new
    @task_assignee.assignee_id = current_user_id
  end

  def create
    @task_assignee.assignee_id = current_user_id

    if @task_assignee.save
      @task.subscribe_user(current_user)
      @task.update_status
      redirect_to @task, notice: 'Assigned to task.'
    else
      render :new
    end
  end

  def destroy
    current_user.task_progressions(@task).unfinished.each(&:finish)
    @task_assignee.destroy
    @task.update_status
    redirect_to @task, notice: 'Unassigned from task.'
  end
end
