# frozen_string_literal: true

class TaskClosuresController < ApplicationController
  load_and_authorize_resource :task, only: %i[new create]
  load_and_authorize_resource through: :task, through_association: :closures,
                              only: %i[new create]
  load_and_authorize_resource only: :destroy

  def new; end

  def create
    notice = 'Task was successfully closed.'

    if @task_closure.save
      @task.close
      @task_closure.subscribe_user
      redirect_to @task, notice: notice
    else
      render :new
    end
  end

  def destroy
    notice = 'Task Closure was successfully destroyed.'
    task = @task_closure.task
    @task_closure.destroy
    redirect_to task, notice: notice
  end
end
