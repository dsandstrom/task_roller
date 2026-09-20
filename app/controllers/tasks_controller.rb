class TasksController < ApplicationController
  load_and_authorize_resource :project, only: %i[new create destroy]
  load_and_authorize_resource through: :project, only: %i[new create destroy]
  load_and_authorize_resource only: %i[show edit update]
  authorize_resource only: :index

  check_for_visible_projects only: :new
  before_action :set_new_form_options, only: :new
  before_action :set_form_options, only: :edit

  def index
    @source = build_source
    authorize! :read, @source

    @tasks = build_tasks.accessible_by(current_ability)
                        .with_notifications(current_user, order_by: order_by)
                        .filter_by(build_filters).page(params[:page])
  end

  def finished
    authorize! :approve, Review

    @tasks = Task.all_in_review.all_visible.accessible_by(current_ability)
                 .with_notifications(current_user, order_by: order_by)
                 .filter_by(build_filters).page(params[:page])
  end

  def show
    @project = @task.project
    set_user_resources
    set_task_resources
    return if TaskNotification.where(task: @task, user: current_user).none?

    TaskNotificationsRemovalJob.set(wait: 20.seconds)
                               .perform_later(@task, current_user)
  end

  def new
    @task_branch = build_task_branch
    attrs = @task_branch&.new_target_attrs || {}
    @task.assign_attributes(attrs)
    @task.task_type ||= @task_types.first
  end

  def edit; end

  def create
    respond_to do |format|
      format.html { create_html }
      format.turbo_stream { create_turbo }
    end
  end

  def update
    respond_to do |format|
      format.html { update_html }
      format.turbo_stream { create_turbo }
    end
  end

  def destroy
    @task.destroy
    redirect_to @project, success: 'Task was successfully removed.'
  end

  private

    def build_source
      { user_id: User, project_id: Project, issue_id: Issue,
        category_id: Category }.each do |key, model|
        next unless params[key]

        return model.find(params.expect(key))
      end
    end

    def task_params
      params.expect(task: [:summary, :description, :task_type_id, :issue_id,
                           :priority_level, { assignee_ids: [] }])
    end

    def set_form_options
      @task_types = TaskType.all
      @assignee_options = build_assignee_options
      @issue_options = build_issue_options
    end

    def set_new_form_options
      set_form_options
      @project_options = build_visible_project_options
    end

    def build_tasks
      tasks = @source.tasks
      if @source.respond_to?(:totally_visible?)
        tasks = tasks.all_visible if @source.totally_visible?
      elsif @source.respond_to?(:visible?)
        tasks = tasks.all_visible if @source.visible?
      elsif @source.is_a?(User)
        tasks = tasks.all_visible
      end
      tasks
    end

    def build_task_branch
      if params[:source_issue_id].present?
        build_task_branch_from_issue
      elsif params[:source_task_id].present?
        build_task_branch_from_task
      end
    end

    def build_task_branch_from_issue
      @trunk_issue = Issue.find(params.expect(:source_issue_id))
      TaskBranch.new(source_issue: @trunk_issue,
                     issue_comment_id: params[:issue_comment_id])
    end

    def build_task_branch_from_task
      @trunk_task = Task.find(params.expect(:source_task_id))
      TaskBranch.new(source_task: @trunk_task,
                     task_comment_id: params[:task_comment_id])
    end

    def set_user_resources
      @user = @task.user
      @assignees = @task.assignees.includes(:progressions)
      @assigned = @task.assigned
    end

    def set_task_resources
      set_subscription
      set_connections
      @comments = @task.comments.preload(:user)
      @notifications = @task.notifications.where(user_id: current_user_id)
                            .where(event: %w[new status])
                            .order(created_at: :desc)
      @progressions = @task.progressions.unfinished
                           .where(user_id: current_user_id)
    end

    def set_subscription
      @subscription = @task.task_subscriptions
                           .find_or_initialize_by(user_id: current_user_id)
    end

    def set_connections
      @source_connection = @task.source_connection
      @duplicates = @task.duplicates
      @siblings = @task.siblings
      @branch_issues = @task.branch_issues
      @branch_tasks = @task.branch_tasks
      @trunk_issue = @task.trunk_issue
      @trunk_task = @task.trunk_task
    end

    def create_html
      if @task.save
        create_task_branch
        subscribe_users
        update_statuses
        redirect_to @task, success: 'Task was successfully added.'
      else
        set_new_form_options
        render :new
      end
    end

    def update_statuses
      @task.update_status(current_user)
      @task.issue&.update_status(current_user)
      @task.issue&.update_priority_level
    end

    def create_turbo
      return if params[:task][:issue_id].blank?

      @issue = Issue.find(params.expect(task: [:issue_id])[:issue_id])
    end

    def update_html
      old_issue = @task.issue
      if @task.update(task_params)
        @task.subscribe_assignees
        @task.update_status(current_user)
        @task.update_issues(old_issue, current_user)
        redirect_to @task, success: 'Task was successfully updated.'
      else
        set_form_options
        render :edit
      end
    end

    def subscribe_users
      @task.subscribe_user
      TaskSubscriptionsJob.perform_later(@task, send_new: true)
      TaskAssigneesSubscriptionsJob.perform_later(@task, send_new: true)
    end

    def create_task_branch
      return unless params[:task_branch]

      TaskBranch.create(
        target: @task,
        source_issue_id: task_branch_params[:source_issue_id],
        source_task_id: task_branch_params[:source_task_id],
        issue_comment_id: task_branch_params[:issue_comment_id],
        task_comment_id: task_branch_params[:task_comment_id],
        user: current_user
      )
    end
end
