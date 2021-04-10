# frozen_string_literal: true

class ProjectIssuesSubscriptionsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource through: :project

  def new; end

  def create
    if @project_issues_subscription.save
      create_success
    else
      create_failure
    end
  end

  def destroy
    notice = "No longer subscribed to future issues for #{@project.name}"
    @project_issues_subscription.destroy
    respond_to do |format|
      format.html { redirect_back fallback_location: @project, notice: notice }
      format.js { new_js }
    end
  end

  private

    def create_success
      notice = "Subscribed to future issues for #{@project.name}"
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
      @project_issues_subscription =
        @project.project_issues_subscriptions.build(user_id: current_user.id)
      authorize! :create, @project_issues_subscription

      render :new
    end
end
