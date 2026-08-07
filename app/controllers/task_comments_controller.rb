class TaskCommentsController < ApplicationController
  load_and_authorize_resource :task
  load_and_authorize_resource through: :task, through_association: :comments

  def show
    redirect_to task_path(@task, anchor: "comment-#{@task_comment.id}")
  end

  def new; end

  def edit; end

  def create
    if @task_comment.save
      @task_comment.subscribe_user
      @task_comment.notify_subscribers

      respond_to do |format|
        format.html { redirect_to redirect_url }
        format.turbo_stream
      end
    else
      render :new
    end
  end

  def update
    if @task_comment.update(task_comment_params)
      respond_to do |format|
        format.html { redirect_to redirect_url, notice: update_notice }
        format.turbo_stream { redirect_to redirect_url }
      end
    else
      render :edit
    end
  end

  def destroy
    @task_comment.destroy

    respond_to do |format|
      format.html { redirect_to @task, notice: destroy_notice }
      format.turbo_stream
    end
  end

  private

    def redirect_url
      @redirect_url ||= task_url(@task, anchor: "comment-#{@task_comment.id}")
    end

    def task_comment_params
      params.expect(task_comment: [:body])
    end

    def update_notice
      'Comment was successfully updated.'
    end

    def destroy_notice
      'Comment was successfully destroyed.'
    end
end
