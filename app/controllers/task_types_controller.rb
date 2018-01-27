# frozen_string_literal: true

class TaskTypesController < ApplicationController
  before_action :set_task_type, only: %i[show edit update destroy]

  def index
    @task_types = TaskType.all
  end

  def new
    @task_type = TaskType.new
  end

  def edit; end

  def create
    @task_type = TaskType.new(task_type_params)

    if @task_type.save
      redirect_to @task_type, notice: 'Task type was successfully created.'
    else
      render :new
    end
  end

  def update
    if @task_type.update(task_type_params)
      redirect_to @task_type, notice: 'Task type was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @task_type.destroy
    redirect_to task_types_url, notice: 'Task type was successfully destroyed.'
  end

  private

    def set_task_type
      @task_type = TaskType.find(params[:id])
    end

    def task_type_params
      params.require(:task_type).permit(:name, :icon, :color)
    end
end
