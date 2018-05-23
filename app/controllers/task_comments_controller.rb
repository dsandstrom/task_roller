# frozen_string_literal: true

class TaskCommentsController < ApplicationController
  before_action :set_category, :set_project, :set_task
  before_action :set_task_comment, only: %i[edit update destroy]

  def new
    @task_comment = @task.comments.build
  end

  def edit
  end

  def create
    @task_comment = @task.comments.build(task_comment_params)

    if @task_comment.save
      redirect_to category_project_task_url(@category, @project, @task),
                  notice: 'Task comment was successfully created.'
    else
      render :new
    end
  end

  def update
    if @task_comment.update(task_comment_params)
      redirect_to category_project_task_url(@category, @project, @task),
                  notice: 'Task comment was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @task_comment.destroy
    redirect_to category_project_task_url(@category, @project, @task),
                notice: 'Task comment was successfully destroyed.'
  end

  private

    def set_task
      @task = Task.find(params[:task_id])
    end

    def set_task_comment
      @task_comment = @task.comments.find(params[:id])
    end

    def task_comment_params
      params.require(:task_comment).permit(:user_id, :body)
    end
end
