# frozen_string_literal: true

class ProjectTaskSubscriptionsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource through: :project

  def new; end

  def create
    if @project_task_subscription.save
      redirect_back fallback_location: @project,
                    notice: 'Subscribed to Project Tasks'
    else
      render :new
    end
  end

  def destroy
    @project_task_subscription.destroy
    redirect_back fallback_location: @project,
                  notice: 'Unsubscribed from Project Tasks'
  end
end
