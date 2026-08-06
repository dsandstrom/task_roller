class ProjectTasksSubscriptionsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource through: :project

  def new; end

  def create
    if @project_tasks_subscription.save
      respond_to do |format|
        format.html do
          redirect_back_or_to(@project, notice: create_notice)
        end
        format.turbo_stream { redirect_back_or_to(@project) }
      end
    else
      render :new
    end
  end

  def destroy
    @project_tasks_subscription.destroy

    respond_to do |format|
      format.html { redirect_back_or_to(@project, notice: notice) }
      format.turbo_stream { redirect_back_or_to(@project) }
    end
  end

  private

    def create_notice
      "Subscribed to future tasks for #{@project.name}"
    end

    def destroy_notice
      "No longer subscribed to future tasks for #{@project.name}"
    end
end
