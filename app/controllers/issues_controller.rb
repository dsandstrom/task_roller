class IssuesController < ApplicationController
  load_and_authorize_resource :project, only: %i[destroy]
  load_and_authorize_resource through: :project, only: %i[destroy]
  load_and_authorize_resource only: %i[show create edit update]
  authorize_resource only: :index

  before_action :set_new_form_options, only: :new
  before_action :set_edit_form_options, only: :edit
  before_action :projects_exist?, only: :new

  def index
    @source = build_source
    authorize! :read, @source

    @issues = build_issues.accessible_by(current_ability)
                          .with_notifications(current_user, order_by: order_by)
                          .filter_by(build_filters).page(params[:page])
  end

  def show
    @user = @issue.user
    @task = @issue.tasks.find(params.expect(:task_id)) if params[:task_id]

    set_issue_variables
    return if IssueNotification.where(issue: @issue, user: current_user).none?

    IssueNotificationsRemovalJob.set(wait: 30.seconds)
                                .perform_later(@issue, current_user)
  end

  def new
    authorize! :create, Issue

    @issue_branch = build_issue_branch
    @issue = build_issue
    @project = @issue.project if @issue.project
  end

  def edit; end

  def create
    if @issue.save
      create_issue_branch
      @issue.subscribe_user
      IssueSubscriptionsJob.perform_later(@issue, send_new: true)
      @issue.update_status(current_user)
      redirect_to @issue, success: 'Issue was successfully created.'
    else
      set_new_form_options
      render :new
    end
  end

  def update
    if @issue.update(issue_update_params)
      @issue.update_status(current_user)
      redirect_to @issue, success: 'Issue was successfully updated.'
    else
      set_edit_form_options
      render :edit
    end
  end

  def destroy
    @issue.destroy
    redirect_to @project, success: 'Issue was successfully destroyed.'
  end

  private

    def issue_params
      params.expect(issue: %i[summary description issue_type_id project_id])
    end

    def issue_update_params
      params.expect(issue: %i[summary description issue_type_id])
    end

    def issue_branch_params
      params.expect(issue_branch: %i[source_issue_id source_task_id
                                     issue_comment_id task_comment_id])
    end

    def set_new_form_options
      @issue_types = IssueType.all
      @project_options = build_project_options
    end

    def set_edit_form_options
      @issue_types = IssueType.all
    end

    def projects_exist?
      return true if @project_options&.any?

      redirect_to root_url, alert: 'App Error: Projects are required'
      false
    end

    def build_source
      if params[:user_id]
        User.find(params.expect(:user_id))
      elsif params[:project_id]
        Project.find(params.expect(:project_id))
      else
        Category.find(params.expect(:category_id))
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

    def build_issue
      attrs = @issue_branch&.new_target_attrs || {}
      current_user.issues.build(
        attrs.merge(issue_type_id: @issue_types.first.id,
                    project_id: params[:project_id])
      )
    end

    def build_issue_branch
      if params[:source_issue_id].present?
        build_issue_branch_from_issue
      elsif params[:source_task_id].present?
        build_issue_branch_from_task
      end
    end

    def build_issue_branch_from_issue
      @trunk_issue = Issue.find(params.expect(:source_issue_id))
      IssueBranch.new(source_issue: @trunk_issue,
                      issue_comment_id: params[:issue_comment_id])
    end

    def build_issue_branch_from_task
      @trunk_task = Task.find(params.expect(:source_task_id))
      IssueBranch.new(source_task: @trunk_task,
                      task_comment_id: params[:task_comment_id])
    end

    def build_project_options
      Category.all_visible.accessible_by(current_ability).map do |category|
        projects = category.projects.all_visible
                           .accessible_by(current_ability).map do |project|
          [project.name, project.id]
        end

        [category.name, projects] if projects.any?
      end.compact
    end

    def set_issue_variables
      set_issue_connection_variables

      @project = @issue.project
      @comments = @issue.comments.includes(:user)
      @notifications = @issue.notifications.where(user_id: current_user_id)
                             .where(event: %w[new status])
                             .order(created_at: :asc)
      @subscription = @issue.issue_subscriptions
                            .find_or_initialize_by(user_id: current_user_id)
    end

    def set_issue_connection_variables
      @source_connection = @issue.source_connection
      @duplicates = @issue.duplicates
      @trunk_issue = @issue.trunk_issue
      @trunk_task = @issue.trunk_task
      @branch_issues = @issue.branch_issues
      @branch_tasks = @issue.branch_tasks
    end

    def create_issue_branch
      return unless params[:issue_branch]

      IssueBranch.create(
        target: @issue,
        source_issue_id: issue_branch_params[:source_issue_id],
        source_task_id: issue_branch_params[:source_task_id],
        issue_comment_id: issue_branch_params[:issue_comment_id],
        task_comment_id: issue_branch_params[:task_comment_id],
        user: current_user
      )
    end
end
