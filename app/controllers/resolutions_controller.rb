# frozen_string_literal: true

class ResolutionsController < ApplicationController
  before_action :authorize_resolution, only: :index
  before_action :set_issue
  before_action :set_resolution, only: %i[edit update destroy]

  def index
    @resolutions = @issue.resolutions
  end

  def new
    @resolution = authorize(@issue.resolutions.build(user_id: current_user.id))
  end

  def approve
    @resolution = authorize(@issue.resolutions.build(user_id: current_user.id))
    if @resolution.approve
      redirect_to category_project_issue_path(@category, @project, @issue),
                  notice: 'Task was successfully marked resolved.'
    else
      render :new
    end
  end

  def disapprove
    @resolution = authorize(@issue.resolutions.build(user_id: current_user.id))
    if @resolution.disapprove
      redirect_to category_project_issue_path(@category, @project, @issue),
                  notice: 'Task was successfully marked unresolved.'
    else
      render :new
    end
  end

  def destroy
    @resolution.destroy
    redirect_to category_project_issue_path(@category, @project, @issue),
                notice: 'Resolution was successfully destroyed.'
  end

  private

    def authorize_resolution
      authorize Resolution
    end

    def set_issue
      @issue = Issue.find(params[:issue_id])
      @project = @issue.project
      @category = @issue.category
      raise ActiveRecord::RecordNotFound unless @category
    end

    def set_resolution
      @resolution = authorize(@issue.resolutions.find(params[:id]))
    end
end
