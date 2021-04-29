# frozen_string_literal: true

class TaskConnectionsController < ApplicationController
  before_action :load_and_authorize, only: %i[new create]
  authorize_resource only: %i[new create]
  load_and_authorize_resource except: %i[new create]

  def new; end

  def create
    notice = 'Task was successfully closed and marked as a duplicate.'

    if @task_connection.save
      @task_connection.source.close
      @task_connection.subscribe_user
      redirect_to @task_connection.source, notice: notice
    else
      render :new
    end
  end

  def destroy
    notice = 'Task was successfully reopened.'
    task = @task_connection.source
    authorize! :read, task

    if @task_connection.destroy
      task.reopen
      task.reopenings.create(user_id: current_user_id)
    end
    redirect_to task, notice: notice
  end

  private

    def load_and_authorize
      target_id = task_connection_params[:target_id] if params[:task_connection]
      @task_connection =
        TaskConnection.new(source_id: params[:source_id], target_id: target_id,
                           user_id: current_user_id)
      authorize! :read, @task_connection.source
    end

    def task_connection_params
      params.require(:task_connection).permit(:target_id)
    end
end
