class TaskSubscriptionsController < ApplicationController
  load_and_authorize_resource :task
  load_and_authorize_resource through: :task

  def new; end

  def create
    if @task_subscription.save
      notice = "Subscribed to Task ##{@task.id}. You will be notified after " \
               'updates.'
      respond_to do |format|
        format.html { redirect_back fallback_location: @task, notice: notice }
        format.turbo_stream { redirect_back fallback_location: @task }
      end
    else
      render :new
    end
  end

  def destroy
    @task_subscription.destroy
    respond_to do |format|
      format.html do
        redirect_back fallback_location: @task,
                      notice: "Unsubscribed from Task ##{@task.id}"
      end
      format.turbo_stream { redirect_back fallback_location: @task }
    end
  end
end
