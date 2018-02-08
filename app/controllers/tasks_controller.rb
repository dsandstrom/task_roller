# frozen_string_literal: true

class TasksController < ApplicationController
  before_action :set_category, :set_project
  before_action :set_task_types, only: %i[new edit]
  before_action :set_task, only: %i[show edit update destroy]

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
      redirect_to category_project_url(@category, @project),
                  alert: 'App Error: Task types are required'
    end
  end

  def edit; end

  def create
    @task = @project.tasks.build(task_params)

    if @task.save
      redirect_to category_project_task_url(@category, @project, @task),
                  success: 'Task was successfully created.'
    else
      set_task_types
      render :new
    end
  end

  def update
    if @task.update(task_params)
      redirect_to category_project_task_url(@category, @project, @task),
                  success: 'Task was successfully updated.'
    else
      set_task_types
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

    def task_params
      params.require(:task)
            .permit(:summary, :description, :task_type_id, :user_id)
    end
end
