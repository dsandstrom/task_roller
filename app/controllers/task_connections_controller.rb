# frozen_string_literal: true

class TaskConnectionsController < ApplicationController
  before_action :build_task_connection, only: %i[new create]
  before_action :set_task_connection, only: :destroy

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
    @task_connection.destroy
    task.reopen
    redirect_to task, notice: notice
  end

  private

    def build_task_connection
      target_id = task_connection_params[:target_id] if params[:task_connection]
      @task_connection =
        TaskConnection.new(source_id: params[:source_id], target_id: target_id)
      authorize! :create, @task_connection
    end

    def set_task_connection
      @task_connection = TaskConnection.find(params[:id])
      authorize! :destroy, @task_connection
    end

    def task_connection_params
      params.require(:task_connection).permit(:target_id)
    end
end
