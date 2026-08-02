class ProjectIssuesSubscriptionsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource through: :project

  def new; end

  def create
    if @project_issues_subscription.save
      respond_to do |format|
        format.html do
          redirect_back fallback_location: @project, notice: create_notice
        end
        format.turbo_stream { redirect_back fallback_location: @project }
      end
    else
      render :new
    end
  end

  def destroy
    @project_issues_subscription.destroy

    respond_to do |format|
      format.html do
        redirect_back fallback_location: @project, notice: destroy_notice
      end
      format.turbo_stream { redirect_back fallback_location: @project }
    end
  end

  private

    def create_notice
      "Subscribed to future issues for #{@project.name}"
    end

    def destroy_notice
      "No longer subscribed to future issues for #{@project.name}"
    end
end
