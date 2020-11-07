# frozen_string_literal: true

# TODO: add js create/destroy response and partials

class TaskSubscriptionsController < ApplicationController
  load_and_authorize_resource :task
  load_and_authorize_resource through: :task

  def new; end

  def create
    if @task_subscription.save
      redirect_back fallback_location: @task, notice: 'Subscribed to Task'
    else
      render :new
    end
  end

  def destroy
    @task_subscription.destroy
    redirect_back fallback_location: @task, notice: 'Unsubscribed from Task'
  end
end
