# frozen_string_literal: true

# TODO: allow admins to connect task to issue, move to different issue
# TODO: restrict to reviewers except index, show
# TODO: when issue, auto assign summary/description
# TODO: add history page to show all progressions, approvals
# TODO: allow creating issue/task from comment
# TODO: add user/tasks action

class TasksController < ApplicationController
  before_action :authorize_task, only: %i[index new create destroy open close]
  before_action :set_category, :set_project, :set_issue, except: %i[open close]
  before_action :set_task, only: %i[show edit update destroy open close]
  before_action :set_form_options, only: %i[new edit]

  def index
    @tasks = Task.filter(build_filters)
  end

  def show
    # TODO: add feed of comments, reviews, progresssions, assignments
  end

  def new
    if @task_types&.any?
      @task = @project.tasks.build(task_type_id: @task_types.first.id)
      @task.issue = @issue
    else
      # TODO: redirect to /issues_types if admin signed in
      redirect_to category_project_url(@category, @project),
                  alert: 'App Error: Task types are required'
    end
  end

  def edit; end

  def create
    build_task
    if @task.save
      redirect_to category_project_task_url(@category, @project, @task),
                  success: 'Task was successfully created.'
    else
      set_form_options
      render :new
    end
  end

  def update
    if @task.update(task_params)
      redirect_to category_project_task_url(@category, @project, @task),
                  success: 'Task was successfully updated.'
    else
      set_form_options
      render :edit
    end
  end

  def destroy
    @task.destroy
    redirect_to category_project_url(@category, @project),
                success: 'Task was successfully destroyed.'
  end

  def open
    if @task.open
      redirect_to category_project_task_url(@category, @project, @task),
                  success: 'Task was successfully opened.'
    else
      set_form_options
      render :edit
    end
  end

  def close
    if @task.close
      redirect_to category_project_task_url(@category, @project, @task),
                  success: 'Task was successfully closed.'
    else
      set_form_options
      render :edit
    end
  end

  private

    def authorize_task
      authorize Task
    end

    def build_task
      @task = @project.tasks.build(task_params)
      @task.issue_id = @issue.to_param if @issue
      @task.user_id = current_user.to_param
      @task.assignee_ids = [current_user.to_param] if current_user.worker?
    end

    def set_task
      if @project
        @task = @project.tasks.find(params[:id])
      else
        @task = Task.find(params[:id])
        @category = @task.category
        @project = @task.project
      end
      authorize @task
    end

    def set_task_types
      @task_types = TaskType.all
    end

    def set_issue
      @issue = @project.issues.find(params[:issue_id]) if params[:issue_id]
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

    # TODO: if reporter, only allow self assign
    def set_assignee_options
      return unless current_user.admin? || current_user.reviewer?

      @assignee_options =
        %w[Worker Reviewer].map do |type|
          employees = User.employees(type).map { |u| [u.name_and_email, u.id] }
          [type.pluralize, employees]
        end
    end

    def set_issue_options
      @issue_options =
        @project.issues.map do |issue|
          [issue.short_summary, issue.id]
        end
    end

    def build_filters
      filters = {}
      %i[status reviewer assigned order].each do |param|
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
