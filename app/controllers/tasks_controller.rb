# frozen_string_literal: true

# TODO: allow admins to  connect task to issue, move to different issue
# TODO: restrict to reviewers except index, show

class TasksController < ApplicationController
  before_action :set_category, :set_project, :set_issue
  before_action :set_task, only: %i[show edit update destroy]
  before_action :set_task_types, :set_user_options, only: %i[new edit]

  def index
    @tasks =
      if @project
        @project.tasks
      else
        @category.tasks
      end
  end

  def show; end

  def new
    if @task_types.any?
      @task = @project.tasks.build(task_type_id: @task_types.first.id)
    else
      # TODO: redirect to /issues_types if admin signed in
      redirect_to category_project_url(@category, @project),
                  alert: 'App Error: Task types are required'
    end
  end

  def edit; end

  def create
    @task = @project.tasks.build(task_params)
    @task.issue = @issue if @issue

    if @task.save
      redirect_to category_project_task_url(@category, @project, @task),
                  success: 'Task was successfully created.'
    else
      set_task_types
      set_user_options
      render :new
    end
  end

  def update
    if @task.update(task_params)
      redirect_to category_project_task_url(@category, @project, @task),
                  success: 'Task was successfully updated.'
    else
      set_task_types
      set_user_options
      render :edit
    end
  end

  def destroy
    @task.destroy
    redirect_to category_project_url(@category, @project),
                success: 'Task was successfully destroyed.'
  end

  private

    def set_task
      @task =
        if @project
          @project.tasks.find(params[:id])
        else
          @category.tasks.find(params[:id])
        end
    end

    def set_task_types
      @task_types = TaskType.all
    end

    def set_issue
      @issue = @project.issues.find(params[:issue_id]) if params[:issue_id]
    end

    def task_params
      params.require(:task)
            .permit(:summary, :description, :task_type_id, :user_id)
    end

    def set_user_options
      # TODO: only set for reviewers, otherwise always current_user
      @user_options =
        %w[Admin Reviewer].map do |type|
          [type, User.employees(type).map { |u| [u.name_and_email, u.id] }]
        end
    end
end
