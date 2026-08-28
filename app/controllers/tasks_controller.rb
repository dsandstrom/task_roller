class TasksController < ApplicationController
  load_and_authorize_resource :project, only: %i[new create destroy]
  load_and_authorize_resource through: :project, only: %i[new create destroy]
  load_and_authorize_resource only: %i[show edit update]
  authorize_resource only: :index

  before_action :set_new_form_options, only: :new
  before_action :set_form_options, only: :edit
  before_action :task_types_exist?, only: %i[new edit]

  def index
    @source = build_source
    authorize! :read, @source

    @tasks = build_tasks.accessible_by(current_ability)
                        .with_notifications(current_user, order_by: order_by)
                        .filter_by(build_filters).page(params[:page])
  end

  def show
    @project = @task.project
    set_user_resources
    set_task_resources
  end

  def new
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

    def task_types_exist?
      return true if @task_types&.any?

      redirect_url = can?(:create, TaskType) ? issue_types_url : root_url
      redirect_to redirect_url, alert: 'App Error: Task Types are required'
      false
    end

    def build_source
      { user_id: User, project_id: Project, issue_id: Issue,
        category_id: Category }.each do |key, model|
        next unless params[key]

        return model.find(params.expect(key))
      end
    end

    def task_params
      params.expect(task: [:summary, :description, :task_type_id, :issue_id,
                           { assignee_ids: [] }])
    end

    def set_form_options
      @task_types = TaskType.all
      @assignee_options = build_assignee_options
      @issue_options = build_issue_options
    end

    def set_new_form_options
      set_form_options
      @project_options = build_project_options
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

    def set_user_resources
      @user = @task.user
      @assignees = @task.assignees.includes(:progressions)
      @assigned = @task.assigned
    end

    def set_task_resources
      @source_connection = @task.source_connection
      @duplicates = @task.duplicates
      @siblings = @task.siblings
      @comments = @task.comments.preload(:user)
      @notifications = @task.notifications.where(user_id: current_user_id)
                            .where(event: %w[new status])
                            .order(created_at: :desc)
      @progressions = @task.progressions.unfinished
                           .where(user_id: current_user_id)
      set_subscription
    end

    def set_subscription
      @subscription = @task.task_subscriptions
                           .find_or_initialize_by(user_id: current_user_id)
    end

    def create_html
      if @task.save
        subscribe_users
        @task.update_status(current_user)
        @task.issue&.update_status(current_user)
        redirect_to @task, success: 'Task was successfully added.'
      else
        set_new_form_options
        render :new
      end
    end

    def create_turbo
      return if params[:task][:issue_id].blank?

      @issue = Issue.find(params.expect(task: [:issue_id])[:issue_id])
    end

    def update_html
      if @task.update(task_params)
        @task.subscribe_assignees
        @task.update_status(current_user)
        @task.issue&.update_status(current_user)
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
end
