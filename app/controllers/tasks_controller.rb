# frozen_string_literal: true

# TODO: allow admins to connect task to issue, move to different issue
# TODO: when issue, auto assign summary/description
# TODO: add history page to show all progressions, approvals
# TODO: allow creating issue/task from comment (another issue_connection?)
# TODO: allow user to customize subscription notifications
# TODO: when closed, lock description & assignees
# TODO: add way to share issue/task url (copy to the clipboard, expandable)

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
    @subscription = build_subscription
  end

  def show
    set_user_resources
    set_task_resources
  end

  def new
    @task.task_type = @task_types.first
  end

  def edit; end

  def create
    if @task.save
      @task.subscribe_users
      redirect_to @task, success: 'Task was successfully created.'
    else
      set_form_options
      render :new
    end
  end

  def update
    if @task.update(task_params)
      @task.subscribe_assignees
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
      if params[:user_id]
        User.find(params[:user_id])
      elsif params[:project_id]
        Project.find(params[:project_id])
      else
        Category.find(params[:category_id])
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

    # TODO: change to just workers after allowing self-assigning
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
      if @source.respond_to?(:visible?) && @source.visible?
        tasks = tasks.all_visible
      end
      tasks.accessible_by(current_ability).filter_by(build_filters)
           .page(params[:page])
    end

    def build_subscription
      return unless @source.is_a?(Project) || @source.is_a?(Category)

      @source.tasks_subscription(current_user, init: true)
    end

    def set_user_resources
      @user = @task.user
      @assignees = @task.assignees.includes(:progressions)
      @assigned = @task.assigned
    end

    def set_task_resources
      @source_connection = @task.source_connection
      @duplicates = @task.duplicates
      @comments = @task.comments.includes(:user)
      @subscription = @task.task_subscriptions
                           .find_or_initialize_by(user_id: current_user.id)
      @progressions = @task.progressions.unfinished
                           .where(user_id: current_user.id)
    end
end
