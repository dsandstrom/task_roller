# frozen_string_literal: true

class TaskReopeningsController < ApplicationController
  load_and_authorize_resource :task, only: %i[new create]
  load_and_authorize_resource through: :task, through_association: :reopenings,
                              only: %i[new create]
  load_and_authorize_resource only: :destroy

  def new; end

  def create
    notice = 'Task was successfully reopened.'

    if @task_reopening.save
      @task.reopen
      @task_reopening.subscribe_user
      redirect_to @task, notice: notice
    else
      render :new
    end
  end

  def destroy
    notice = 'Task Reopening was successfully destroyed.'
    task = @task_reopening.task
    @task_reopening.destroy
    redirect_to task, notice: notice
  end
end
