# frozen_string_literal: true

class ProjectTasksSubscriptionsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource through: :project

  def new; end

  def create
    if @project_tasks_subscription.save
      redirect_back fallback_location: @project,
                    notice: "Subscribed to future tasks for #{@project.name}"
    else
      render :new
    end
  end

  def destroy
    notice = "No longer subscribed to future tasks for #{@project.name}"
    @project_tasks_subscription.destroy
    redirect_back fallback_location: @project, notice: notice
  end
end
