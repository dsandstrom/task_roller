# frozen_string_literal: true

class MoveTasksController < ApplicationController
  load_and_authorize_resource :task
  before_action :authorize_move

  def edit; end

  def update
    if @task.update(task_params)
      redirect_to @task, notice: 'Task was successfully moved.'
    else
      render :edit
    end
  end

  private

    def authorize_move
      authorize! :move, @task
    end

    def task_params
      params.require(:task).permit(:project_id)
    end
end
