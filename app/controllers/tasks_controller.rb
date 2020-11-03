# frozen_string_literal: true

# TODO: allow admins to connect task to issue, move to different issue
# TODO: restrict to reviewers except index, show
# TODO: when issue, auto assign summary/description
# TODO: add history page to show all progressions, approvals
# TODO: allow creating issue/task from comment
# TODO: allow user to customize subscription notifications

class TasksController < ApplicationController
  load_and_authorize_resource :project, only: %i[new create]
  load_and_authorize_resource through: :project, only: %i[new create]
  load_and_authorize_resource only: %i[show edit update destroy open close]
  before_action :set_parent, only: :index
  before_action :set_category_and_project, except: :index
  before_action :set_form_options, only: %i[new edit]
  before_action :check_for_task_types, only: :new

  def index
    authorize! :read, Task

    if @user
      @tasks = @user.tasks
    elsif @project
      @tasks = @project.tasks
      @subscription =
        current_user.project_task_subscription(@project, init: true)
    else
      @tasks = @category.tasks
      @subscription =
        current_user.category_task_subscription(@category, init: true)
    end
    @tasks = @tasks.filter_by(build_filters).page(params[:page])
  end

  def show
    # TODO: add feed of comments, reviews, progresssions, assignments
    @task_subscription =
      @task.task_subscriptions.find_or_initialize_by(user_id: current_user.id)
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

  def open
    if @task.open
      @task.subscribe_user(current_user)
      redirect_to @task, success: 'Task was successfully opened.'
    else
      set_form_options
      render :edit
    end
  end

  def close
    if @task.close
      @task.subscribe_user(current_user)
      redirect_to @task, success: 'Task was successfully closed.'
    else
      set_form_options
      render :edit
    end
  end

  private

    def check_for_task_types
      return true if @task_types&.any?

      redirect_url =
        can?(:create, TaskType) ? roller_types_url : project_url(@project)
      redirect_to redirect_url, alert: 'App Error: Task Types are required'
      false
    end

    def set_parent
      if params[:user_id]
        @user = User.find(params[:user_id])
      elsif params[:project_id]
        @project = Project.find(params[:project_id])
      else
        @category = Category.find(params[:category_id])
      end
    end

    def set_category_and_project
      @project ||= @task.project
      @category ||= @task.category
      true # rubocop complains about memoization
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

    def set_assignee_options
      @assignee_options =
        %w[Worker Reviewer].map do |type|
          employees = User.employees(type).map { |u| [u.name_and_email, u.id] }
          [type.pluralize, employees]
        end
    end

    def set_issue_options
      @issue_options =
        @project.issues.map do |issue|
          [issue.id_and_summary, issue.id]
        end
    end

    def build_filters
      filters = {}
      %i[status order].each do |param|
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
