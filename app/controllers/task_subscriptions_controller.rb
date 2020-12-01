# frozen_string_literal: true

# TODO: add js create/destroy response and partials

class TaskSubscriptionsController < ApplicationController
  load_and_authorize_resource only: :index
  load_and_authorize_resource :task, except: :index
  load_and_authorize_resource through: :task, except: :index

  def index
    # fetch the tasks thru the subscriptions to block invisible/internal
    @subscribed_tasks =
      Task.where(id: @task_subscriptions.map(&:task_id))
          .filter_by(build_filters).page(params[:page])
  end

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
