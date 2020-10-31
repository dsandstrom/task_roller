# frozen_string_literal: true

class TaskCommentsController < ApplicationController
  load_and_authorize_resource :task
  load_and_authorize_resource through: :task, through_association: :comments

  def new; end

  def edit; end

  def create
    if @task_comment.save
      @task_comment.subscribe_user
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
    redirect_to @task, notice: 'Comment was successfully destroyed.'
  end

  private

    def redirect_url
      @redirect_url ||= task_url(@task, anchor: "comment-#{@task_comment.id}")
    end

    def task_comment_params
      params.require(:task_comment).permit(:body)
    end
end
