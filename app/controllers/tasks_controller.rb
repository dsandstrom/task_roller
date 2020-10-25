# frozen_string_literal: true

# TODO: allow admins to connect task to issue, move to different issue
# TODO: restrict to reviewers except index, show
# TODO: when issue, auto assign summary/description
# TODO: add history page to show all progressions, approvals
# TODO: allow creating issue/task from comment
# TODO: add user/tasks action

class TasksController < ApplicationController
  before_action :authorize_task, only: %i[index new create destroy open close]
  before_action :set_category_or_user, only: :index
  before_action :set_project, only: %i[new create]
  before_action :set_issue, only: %i[new create]
  before_action :set_task, except: %i[index new create]
  before_action :set_form_options, only: %i[new edit]

  def index
    @tasks =
      if @user
        @user.tasks
      elsif @project
        @project.tasks
      else
        @category.tasks
      end
    @tasks = @tasks.filter_by(build_filters).page(params[:page])
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
      redirect_to project_url(@project),
                  alert: 'App Error: Task types are required'
    end
  end

  def edit; end

  def create
    build_task
    if @task.save
      redirect_to task_url(@task), success: 'Task was successfully created.'
    else
      set_form_options
      render :new
    end
  end

  def update
    if @task.update(task_params)
      redirect_to task_url(@task), success: 'Task was successfully updated.'
    else
      set_form_options
      render :edit
    end
  end

  def destroy
    @task.destroy
    redirect_to project_url(@project),
                success: 'Task was successfully destroyed.'
  end

  def open
    if @task.open
      redirect_to task_url(@task), success: 'Task was successfully opened.'
    else
      set_form_options
      render :edit
    end
  end

  def close
    if @task.close
      redirect_to task_url(@task), success: 'Task was successfully closed.'
    else
      set_form_options
      render :edit
    end
  end

  private

    def authorize_task
      authorize Task
    end

    def set_category_or_user
      return set_project if params[:project_id].present?

      if params[:user_id]
        @user = User.find(params[:user_id])
      else
        @category = Category.find(params[:category_id])
      end
    end

    def set_project
      @project = Project.find(params[:project_id])
      @category = @project.category
    end

    def set_task
      if @project
        @task = authorize(@project.tasks.find(params[:id]))
      else
        @task = authorize(Task.find(params[:id]))
        @category = @task.category
        @project = @task.project
      end
    end

    def build_task
      @task = @project.tasks.build(task_params)
      @task.issue_id = @issue.to_param if @issue
      @task.user_id = current_user.to_param
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
          [issue.short_summary, issue.id]
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
