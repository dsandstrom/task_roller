class TaskSubscriptionsController < ApplicationController
  load_and_authorize_resource :task
  load_and_authorize_resource through: :task

  def new; end

  def create
    if @task_subscription.save
      respond_to do |format|
        format.html do
          redirect_back fallback_location: @task, notice: create_notice
        end
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
        redirect_back fallback_location: @task, notice: destroy_notice
      end
      format.turbo_stream { redirect_back fallback_location: @task }
    end
  end

  private

    def create_notice
      "Subscribed to Task ##{@task.id}. You will be notified after updates."
    end

    def destroy_notice
      "Unsubscribed from Task ##{@task.id}"
    end
end
