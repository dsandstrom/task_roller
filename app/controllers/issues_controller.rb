# frozen_string_literal: true

class IssuesController < ApplicationController
  before_action :authorize_issue, only: %i[index new show destroy]
  before_action :set_category, :set_project, except: %i[open close]
  before_action :set_issue, only: %i[show edit update destroy open close]
  before_action :set_form_options, only: %i[new edit]

  def index
    @issues = Issue.filter(build_filters)
  end

  def show
    @comments = @issue.comments.includes(:user)
    @comment = @issue.comments.build
  end

  def new
    # TODO: set user_id to current user
    if @issue_types&.any?
      @issue = @project.issues.build(issue_type_id: @issue_types.first.id)
    else
      # TODO: redirect to /issues_types if admin signed in
      redirect_to category_project_url(@category, @project),
                  alert: 'App Error: Issue types are required'
    end
  end

  def edit; end

  def create
    @issue = @project.issues.build(issue_params)
    @issue.user = current_user

    if @issue.save
      redirect_to category_project_issue_url(@category, @project, @issue),
                  success: 'Issue was successfully created.'
    else
      set_form_options
      render :new
    end
  end

  def update
    if @issue.update(issue_params)
      redirect_to category_project_issue_url(@category, @project, @issue),
                  success: 'Issue was successfully updated.'
    else
      set_form_options
      render :edit
    end
  end

  def destroy
    @issue.destroy
    redirect_to category_project_url(@category, @project),
                success: 'Issue was successfully destroyed.'
  end

  def open
    @project = @issue.project
    @category = @issue.category
    if @issue.open
      redirect_to category_project_issue_url(@category, @project, @issue),
                  success: 'Issue was successfully opened.'
    else
      set_form_options
      render :edit
    end
  end

  def close
    @project = @issue.project
    @category = @issue.category
    if @issue.close
      redirect_to category_project_issue_url(@category, @project, @issue),
                  success: 'Issue was successfully closed.'
    else
      set_form_options
      render :edit
    end
  end

  private

    def authorize_issue
      authorize Issue
    end

    def set_issue
      if @project
        @issue = @project.issues.find(params[:id])
        authorize @issue
      else
        @issue = Issue.find(params[:id])
        authorize @issue
        @category = @issue.category
        @project = @issue.project
      end
    end

    def set_issue_types
      @issue_types = IssueType.all
    end

    def set_form_options
      set_issue_types
    end

    def issue_params
      params.require(:issue).permit(:summary, :description, :issue_type_id)
    end

    def build_filters
      filters = {}
      %i[status reporter order].each do |param|
        filters[param] = params[param]
      end
      if @project
        filters[:project] = @project
      else
        filters[:category] = @category
      end
      filters
    end
end
