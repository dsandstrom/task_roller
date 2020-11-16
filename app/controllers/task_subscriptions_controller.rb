# frozen_string_literal: true

# TODO: add js create/destroy response and partials

class TaskSubscriptionsController < ApplicationController
  load_and_authorize_resource only: :index
  load_and_authorize_resource :task, except: :index
  load_and_authorize_resource through: :task, except: :index

  def index
    @subscribed_tasks =
      current_user.subscribed_tasks.accessible_by(current_ability)
                  .filter_by(build_filters).page(params[:page])
  end

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
