# frozen_string_literal: true

class TaskCommentsController < ApplicationController
  load_and_authorize_resource :task
  load_and_authorize_resource through: :task, through_association: :comments

  def new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    respond_to do |format|
      format.html do
        redirect_to task_path(@task, anchor: "comment-#{@task_comment.id}")
      end
      format.js
    end
  end

  def create
    if @task_comment.save
      @task_comment.subscribe_user
      @task_comment.notify_subscribers
      create_success
    else
      create_failure
    end
  end

  def update
    if @task_comment.update(task_comment_params)
      update_success
    else
      update_failure
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

    def create_success
      respond_to do |format|
        format.html { redirect_to redirect_url }
        format.js { render :show }
      end
    end

    def create_failure
      respond_to do |format|
        format.html { render :new }
        format.js { render :new }
      end
    end

    def update_success
      respond_to do |format|
        format.html do
          redirect_to redirect_url, notice: 'Comment was successfully updated.'
        end
        format.js { render :show }
      end
    end

    def update_failure
      respond_to do |format|
        format.html { render :edit }
        format.js do
          @task_comment.reload
          render :show
        end
      end
    end
end
