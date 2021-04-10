# frozen_string_literal: true

class ProjectTasksSubscriptionsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource through: :project

  def new; end

  def create
    if @project_tasks_subscription.save
      create_success
    else
      create_failure
    end
  end

  def destroy
    notice = "No longer subscribed to future tasks for #{@project.name}"
    @project_tasks_subscription.destroy
    respond_to do |format|
      format.html { redirect_back fallback_location: @project, notice: notice }
      format.js { new_js }
    end
  end

  private

    def create_success
      notice = "Subscribed to future tasks for #{@project.name}"
      respond_to do |format|
        format.html do
          redirect_back fallback_location: @project, notice: notice
        end
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
      @project_tasks_subscription =
        @project.project_tasks_subscriptions.build(user_id: current_user.id)
      authorize! :create, @project_tasks_subscription

      render :new
    end
end
