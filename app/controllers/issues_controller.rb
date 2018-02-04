# frozen_string_literal: true

class IssuesController < ApplicationController
  before_action :set_category, :set_project
  before_action :set_issue, only: %i[show edit update destroy]
  before_action :set_issue_types, :set_user_options, only: %i[new edit]

  def index
    @issues =
      if @category && @project
        @project.issues
      elsif @category
        @category.issues
      else
        Issue.all
      end
  end

  def show; end

  def new
    # TODO: set user_id to current user
    if @issue_types.any?
      @issue = @project.issues.build(issue_type_id: @issue_types.first.id)
    else
      redirect_to category_project_url(@category, @project),
                  alert: 'Invalid configuration: Issue types are required'
    end
  end

  def edit; end

  def create
    @issue = @project.issues.build(issue_params)

    if @issue.save
      redirect_to category_project_issue_url(@category, @project, @issue),
                  success: 'Issue was successfully created.'
    else
      set_issue_types
      set_user_options
      render :new
    end
  end

  def update
    if @issue.update(issue_params)
      redirect_to category_project_issue_url(@category, @project, @issue),
                  success: 'Issue was successfully updated.'
    else
      set_issue_types
      set_user_options
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
      return unless params[:category_id]
      @category = Category.find(params[:category_id])
    end

    def set_project
      return unless @category && params[:project_id]
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

    def set_issue_types
      @issue_types = IssueType.all
    end

    def issue_params
      # TODO: set user_id from logged in user
      params.require(:issue)
            .permit(:summary, :description, :issue_type_id, :user_id)
    end

    def set_user_options
      # TODO: only set for reviewers, otherwise always current_user
      @user_options =
        User::VALID_EMPLOYEE_TYPES.map do |type|
          [type, User.employees(type).map { |u| [u.name_and_email, u.id] }]
        end
    end
end
