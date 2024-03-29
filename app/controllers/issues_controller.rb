# frozen_string_literal: true

# TODO: add one place to add issues (able to pick project there)
# TODO: add all issues page, filter by category/project
# TODO: add general search
# TODO: allow to update status of multiple issues/task

class IssuesController < ApplicationController
  load_and_authorize_resource :project, only: %i[new create destroy]
  load_and_authorize_resource through: :project, only: %i[new create destroy]
  load_and_authorize_resource only: %i[show edit update]
  authorize_resource only: :index

  before_action :set_form_options, only: %i[new edit]
  before_action :check_for_issue_types, only: :new

  def index
    @source = build_source
    authorize! :read, @source

    @issues = build_issues.accessible_by(current_ability)
                          .with_notifications(current_user, order_by: order_by)
                          .filter_by(build_filters).page(params[:page])
  end

  def show
    # TODO: destroy 'new' notifications for current_user
    @user = @issue.user

    respond_to do |format|
      format.html { set_issue_variables }
      format.js do
        @task = @issue.tasks.find(params[:task_id]) if params[:task_id]
      end
    end
  end

  def new
    if @issue_types&.any?
      @issue = @project.issues.build(issue_type_id: @issue_types.first.id,
                                     user_id: current_user_id)
      authorize! :create, @issue
    else
      # TODO: raise error in ApplicationController and rescue/redirect
      redirect_url = can?(:create, IssueType) ? issue_types_url : @project
      redirect_to redirect_url, alert: 'App Error: Issue Types are required'
    end
  end

  def edit; end

  def create
    if @issue.save
      @issue.subscribe_users
      @issue.update_status(current_user)
      redirect_to @issue, success: 'Issue was successfully created.'
    else
      set_form_options
      render :new
    end
  end

  def update
    if @issue.update(issue_params)
      @issue.update_status(current_user)
      redirect_to @issue, success: 'Issue was successfully updated.'
    else
      set_form_options
      render :edit
    end
  end

  def destroy
    @issue.destroy
    redirect_to @project, success: 'Issue was successfully destroyed.'
  end

  private

    def issue_params
      params.require(:issue).permit(:summary, :description, :issue_type_id)
    end

    def set_form_options
      @issue_types = IssueType.all
    end

    def check_for_issue_types
      return true if @issue_types&.any?

      redirect_url = can?(:create, IssueType) ? issue_types_url : root_url
      redirect_to redirect_url, alert: 'App Error: Issue Types are required'
      false
    end

    def build_source
      if params[:user_id]
        User.find(params[:user_id])
      elsif params[:project_id]
        Project.find(params[:project_id])
      else
        Category.find(params[:category_id])
      end
    end

    def build_issues
      issues = @source.issues
      if @source.respond_to?(:totally_visible?)
        issues = issues.all_visible if @source.totally_visible?
      elsif @source.respond_to?(:visible?)
        issues = issues.all_visible if @source.visible?
      elsif @source.is_a?(User)
        issues = issues.all_visible
      end
      issues
    end

    def set_issue_variables
      @project = @issue.project
      @comments = @issue.comments.includes(:user)
      @notifications = @issue.notifications.where(user_id: current_user_id)
                             .where(event: %w[new status])
                             .order(created_at: :asc)
      @source_connection = @issue.source_connection
      @duplicates = @issue.duplicates
      @source_connection = @issue.source_connection
      @subscription = @issue.issue_subscriptions
                            .find_or_initialize_by(user_id: current_user_id)
    end

    def order_by
      @order_by ||= params[:order].blank? || params[:order] == 'updated,desc'
    end
end
