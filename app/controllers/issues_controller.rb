# frozen_string_literal: true

# TODO: add user/issues action

class IssuesController < ApplicationController
  before_action :authorize_issue, only: %i[index new show destroy]
  before_action :set_category_or_project, only: :index
  before_action :set_project, only: %i[new create]
  before_action :set_issue, except: %i[index new create]
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
      redirect_to issue_url(@issue), success: 'Issue was successfully created.'
    else
      set_form_options
      render :new
    end
  end

  def update
    if @issue.update(issue_params)
      redirect_to issue_url(@issue), success: 'Issue was successfully updated.'
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
      redirect_to issue_url(@issue), success: 'Issue was successfully opened.'
    else
      set_form_options
      render :edit
    end
  end

  def close
    @project = @issue.project
    @category = @issue.category
    if @issue.close
      redirect_to issue_url(@issue), success: 'Issue was successfully closed.'
    else
      set_form_options
      render :edit
    end
  end

  private

    def authorize_issue
      authorize Issue
    end

    def set_category_or_project
      return set_project if params[:project_id].present?

      @category = Category.find(params[:category_id])
    end

    def set_project
      @project = Project.find(params[:project_id])
      @category = @project.category
    end

    def set_issue
      @issue = authorize(Issue.find(params[:id]))
      @category = @issue.category
      @project = @issue.project
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
      elsif @category
        filters[:category] = @category
      end
      filters
    end
end
