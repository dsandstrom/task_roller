# frozen_string_literal: true

class TaskSubscriptionsController < ApplicationController
  load_and_authorize_resource :task
  load_and_authorize_resource through: :task

  def new; end

  def create
    if @task_subscription.save
      create_success
    else
      create_failure
    end
  end

  def destroy
    @task_subscription.destroy
    respond_to do |format|
      format.html do
        redirect_back fallback_location: @task,
                      notice: "Unsubscribed from Task ##{@task.id}"
      end
      format.js { new_js }
    end
  end

  private

    def create_success
      notice = "Subscribed to Task ##{@task.id}. You will be notified after "\
               'updates.'
      respond_to do |format|
        format.html { redirect_back fallback_location: @task, notice: notice }
        format.js { render :show }
      end
    end

    def create_failure
      respond_to do |format|
        format.html { render :new }
        format.js { new_js }
      end
    end

    def new_js
      @task_subscription =
        @task.task_subscriptions.build(user_id: current_user_id)
      authorize! :create, @task_subscription

      render :new
    end
end
