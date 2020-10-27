# frozen_string_literal: true

# TODO: create subscription on create
# TODO: create subscription when assigned

class TaskCommentsController < ApplicationController
  before_action :authorize_task_comment, only: %i[index new create destroy]
  before_action :set_task, only: %i[new create]
  before_action :set_task_comment, only: %i[edit update destroy]

  def new
    @task_comment = @task.comments.build
  end

  def edit
  end

  def create
    @task_comment = @task.comments.build(task_comment_params)
    @task_comment.user_id = current_user.id

    if @task_comment.save
      redirect_to redirect_url, notice: 'Comment was successfully created.'
    else
      render :new
    end
  end

  def update
    if @task_comment.update(task_comment_params)
      redirect_to redirect_url, notice: 'Comment was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @task_comment.destroy
    redirect_to task_url(@task),
                notice: 'Comment was successfully destroyed.'
  end

  private

    def authorize_task_comment
      authorize TaskComment
    end

    def set_task
      @task = Task.find(params[:task_id])
    end

    def set_task_comment
      @task_comment = authorize(TaskComment.find(params[:id]))
      @task = @task_comment.task
    end

    def redirect_url
      @redirect_url ||= task_url(@task, anchor: "comment-#{@task_comment.id}")
    end

    def task_comment_params
      params.require(:task_comment).permit(:body)
    end
end
