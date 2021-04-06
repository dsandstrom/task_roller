# frozen_string_literal: true

class TaskSubscriptionsController < ApplicationController
  load_and_authorize_resource :task
  load_and_authorize_resource through: :task

  def new; end

  def create
    if @task_subscription.save
      notice = 'Subscribed to Task. You will be notified of future updates.'
      redirect_back fallback_location: @task, notice: notice
    else
      render :new
    end
  end

  def destroy
    @task_subscription.destroy
    redirect_back fallback_location: @task, notice: 'Unsubscribed from Task'
  end
end
