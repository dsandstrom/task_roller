# frozen_string_literal: true

class IssuesController < ApplicationController
  before_action :set_category, :set_project, except: :index
  before_action :set_issue, only: %i[show edit update destroy]

  def index
    @issues = Issue.all
  end

  def show; end

  def new
    @issue = @project.issues.build
  end

  def edit; end

  def create
    @issue = @project.issues.build(issue_params)

    if @issue.save
      redirect_to category_project_issue_url(@category, @project, @issue),
                  success: 'Issue was successfully created.'
    else
      render :new
    end
  end

  def update
    if @issue.update(issue_params)
      redirect_to category_project_issue_url(@category, @project, @issue),
                  success: 'Issue was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @issue.destroy
    redirect_to category_project_url(@category, @project),
                success: 'Issue was successfully destroyed.'
  end

  private

    def set_category
      @category = Category.find(params[:category_id])
    end

    def set_project
      return unless params[:project_id]
      @project = @category.projects.find(params[:project_id])
    end

    def set_issue
      @issue =
        if @project
          @project.issues.find(params[:id])
        else
          @category.issues.find(params[:id])
        end
    end

    def issue_params
      # TODO: set user_id from logged in user
      params.require(:issue)
            .permit(:summary, :description, :issue_type_id, :user_id)
    end
end
