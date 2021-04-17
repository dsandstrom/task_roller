# frozen_string_literal: true

class TasksController < ApplicationController
  load_and_authorize_resource :project, only: %i[new create destroy]
  load_and_authorize_resource through: :project, only: %i[new create destroy]
  load_and_authorize_resource only: %i[show edit update]
  authorize_resource only: :index

  before_action :set_form_options, only: %i[new edit]
  before_action :check_for_task_types, only: %i[new edit]

  def index
    @source = build_source
    authorize! :read, @source

    @tasks = build_tasks
  end

  def show
    respond_to do |format|
      format.html do
        set_user_resources
        set_task_resources
      end
      format.js
    end
  end

  def new
    @task.task_type = @task_types.first
  end

  def edit; end

  def create
    if @task.save
      @task.subscribe_users
      @task.update_status(current_user)
      @task.issue&.update_status(current_user)
      redirect_to @task, success: 'Task was successfully created.'
    else
      set_form_options
      render :new
    end
  end

  def update
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

  def destroy
    @task.destroy
    redirect_to @project, success: 'Task was successfully destroyed.'
  end

  private

    def check_for_task_types
      return true if @task_types&.any?

      redirect_url = can?(:create, TaskType) ? issue_types_url : root_url
      redirect_to redirect_url, alert: 'App Error: Task Types are required'
      false
    end

    def build_source
      { user_id: User, project_id: Project, issue_id: Issue,
        category_id: Category }.each do |key, model|
        next unless params[key]

        return model.find(params[key])
      end
    end

    def task_params
      params.require(:task).permit(:summary, :description, :task_type_id,
                                   :issue_id, assignee_ids: [])
    end

    def set_form_options
      @task_types = TaskType.all
      @assignee_options = build_assignee_options
      @issue_options = build_issue_options
    end

    def build_assignee_options
      %w[Worker Reviewer].map do |type|
        employees = User.employees(type).map { |u| [u.name_and_email, u.id] }
        [type.pluralize, employees]
      end
    end

    def build_issue_options
      @task.project.issues.map do |issue|
        [issue.id_and_summary, issue.id]
      end
    end

    def build_tasks
      tasks = @source.tasks
      if @source.respond_to?(:totally_visible?)
        tasks = tasks.all_visible if @source.totally_visible?
      elsif @source.respond_to?(:visible?)
        tasks = tasks.all_visible if @source.visible?
      end
      tasks.accessible_by(current_ability).filter_by(build_filters)
           .page(params[:page])
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
      @comments = @task.comments.includes(:user)
      @subscription = @task.task_subscriptions
                           .find_or_initialize_by(user_id: current_user.id)
      @progressions = @task.progressions.unfinished
                           .where(user_id: current_user.id)
    end
end
