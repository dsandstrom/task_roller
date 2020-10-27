# frozen_string_literal: true

# TODO: add js create/destroy response and partials

class TaskSubscriptionsController < ApplicationController
  before_action :authorize_task_subscription, only: %i[index new create]
  before_action :set_task, only: %i[new create]
  before_action :build_task_subscription, only: %i[new create]
  before_action :set_task_subscription, only: %i[show edit update destroy]

  def index
    @tasks = current_user.subscribed_tasks.apply_filters(build_filters)
                         .page(params[:page])
  end

  def new
  end

  def create
    if @task_subscription.save
      redirect_to @task, notice: 'Subscribed to Task'
    else
      render :new
    end
  end

  def destroy
    @task_subscription.destroy
    redirect_to @task, notice: 'Unsubscribed from Task'
  end

  private

    def authorize_task_subscription
      authorize TaskSubscription
    end

    def set_task
      @task = Task.find(params[:task_id])
    end

    def set_task_subscription
      @task_subscription = authorize(TaskSubscription.find(params[:id]))
      @task = @task_subscription.task
    end

    def build_task_subscription
      @task_subscription =
        @task.task_subscriptions.build(user_id: current_user.id)
    end
end
