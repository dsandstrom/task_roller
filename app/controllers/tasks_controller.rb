# frozen_string_literal: true

# TODO: allow admins to connect task to issue, move to different issue
# TODO: when issue, auto assign summary/description
# TODO: add history page to show all progressions, approvals
# TODO: allow creating issue/task from comment (another issue_connection?)
# TODO: allow user to customize subscription notifications
# TODO: when closed, lock description & assignees
# TODO: add way to share issue/task url (copy to the clipboard, expandable)

class TasksController < ApplicationController
  load_and_authorize_resource :project, only: %i[new create]
  load_and_authorize_resource through: :project, only: %i[new create]
  load_and_authorize_resource except: %i[index new create]
  before_action :set_source, only: :index
  before_action :set_form_options, only: %i[new edit]
  before_action :check_for_task_types, only: :new

  def index
    authorize! :read, Task

    set_tasks
    set_subscription
  end

  def show
    @comments = @task.comments.includes(:user)
    @user = @task.user
    @assignees = @task.assignees.includes(:progressions)
    @assigned = @task.assigned
    @review = @task.current_review
    @source_connection = @task.source_connection
    @subscription =
      @task.task_subscriptions.find_or_initialize_by(user_id: current_user.id)
    @progressions =
      @task.progressions.unfinished.where(user_id: current_user.id)
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
    project = @task.project
    @task.destroy
    redirect_to project, success: 'Task was successfully destroyed.'
  end

  private

    def check_for_task_types
      return true if @task_types&.any?

      redirect_url = can?(:create, TaskType) ? issue_types_url : root_url
      redirect_to redirect_url, alert: 'App Error: Task Types are required'
      false
    end

    def set_source
      @source =
        if params[:user_id]
          User.find(params[:user_id])
        elsif params[:project_id]
          Project.find(params[:project_id])
        else
          Category.find(params[:category_id])
        end
      authorize! :read, @source
    end

    def task_params
      params.require(:task).permit(:summary, :description, :task_type_id,
                                   :issue_id, assignee_ids: [])
    end

    def set_form_options
      set_task_types
      set_assignee_options
      set_issue_options
    end

    def set_task_types
      @task_types = TaskType.all
    end

    # TODO: change to just workers after allowing self-assigning
    def set_assignee_options
      @assignee_options =
        %w[Worker Reviewer].map do |type|
          employees = User.employees(type).map { |u| [u.name_and_email, u.id] }
          [type.pluralize, employees]
        end
    end

    def set_issue_options
      @issue_options =
        @task.project.issues.map do |issue|
          [issue.id_and_summary, issue.id]
        end
    end

    def set_tasks
      @tasks = @source.tasks.accessible_by(current_ability)
                      .filter_by(build_filters).page(params[:page])
    end

    def set_subscription
      return unless @source.is_a?(Project) || @source.is_a?(Category)

      @subscription = @source.tasks_subscription(current_user, init: true)
    end
end
