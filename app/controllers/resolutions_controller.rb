# frozen_string_literal: true

class ResolutionsController < ApplicationController
  before_action :set_issue
  before_action :set_resolution, except: %i[index new create]

  def index
    @resolutions = @issue.resolutions
  end

  def new
    @resolution = @issue.resolutions.build
  end

  def edit
  end

  def create
    @resolution = @issue.resolutions.build(resolution_params)

    if @resolution.save
      redirect_to category_project_issue_path(@category, @project, @issue),
                  notice: 'Resolution was successfully created.'
    else
      render :new
    end
  end

  # TODO: set issue.user_id as current user
  def approve
    if @resolution.approve
      redirect_to category_project_issue_path(@category, @project, @issue),
                  notice: 'Resolution was successfully updated.'
    else
      render :edit
    end
  end

  # TODO: set issue.user_id as current user
  def disapprove
    if @resolution.disapprove
      redirect_to category_project_issue_path(@category, @project, @issue),
                  notice: 'Resolution was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @resolution.destroy
    redirect_to category_project_issue_path(@category, @project, @issue),
                notice: 'Resolution was successfully destroyed.'
  end

  private

    # TODO: authorize access
    def set_issue
      @issue = Issue.find(params[:issue_id])
      @project = @issue.project
      @category = @issue.category
      raise ActiveRecord::RecordNotFound unless @category
    end

    def set_resolution
      @resolution = @issue.resolutions.find(params[:id])
    end

    def resolution_params
      params.require(:resolution).permit(:user_id)
    end
end
