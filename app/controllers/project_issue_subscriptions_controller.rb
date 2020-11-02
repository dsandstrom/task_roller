# frozen_string_literal: true

class ProjectIssueSubscriptionsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource through: :project

  def new; end

  def create
    if @project_issue_subscription.save
      redirect_back fallback_location: @project,
                    notice: 'Subscribed to Project Issues'
    else
      render :new
    end
  end

  def destroy
    @project_issue_subscription.destroy
    redirect_back fallback_location: @project,
                  notice: 'Unsubscribed from Project Issues'
  end
end
