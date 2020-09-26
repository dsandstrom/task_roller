# frozen_string_literal: true

class TaskConnectionsController < ApplicationController
  before_action :build_task_connection, only: :create
  before_action :set_task_connection, only: :destroy

  def new
    @task_connection = TaskConnection.new(source_id: params[:source_id])
  end

  def create
    notice = 'Task was successfully closed and marked as a duplicate.'

    if @task_connection.save
      @task_connection.source.close
      path = category_project_task_path(@task_connection.source.category,
                                        @task_connection.source.project,
                                        @task_connection.source)
      redirect_to path, notice: notice
    else
      render :new
    end
  end

  def destroy
    notice = 'Task was successfully reopened.'
    path = category_project_task_path(@task_connection.source.category,
                                      @task_connection.source.project,
                                      @task_connection.source)
    @task_connection.destroy
    @task_connection.source.open
    redirect_to path, notice: notice
  end

  private

    def build_task_connection
      @task_connection =
        TaskConnection.new(source_id: params[:source_id],
                           target_id: task_connection_params[:target_id])
    end

    def set_task_connection
      @task_connection = TaskConnection.find(params[:id])
    end

    def task_connection_params
      params.require(:task_connection).permit(:target_id)
    end
end
