# frozen_string_literal: true

class TaskTypesController < ApplicationController
  before_action :authorize_task_type
  before_action :set_task_type, only: %i[edit update destroy]

  def new
    @task_type = TaskType.new(color: 'default', icon: 'bulb')
    authorize @task_type
  end

  def edit; end

  def create
    @task_type = TaskType.new(task_type_params)
    authorize @task_type

    if @task_type.save
      redirect_to roller_types_url,
                  success: 'Task type was successfully created.'
    else
      render :new
    end
  end

  def update
    if @task_type.update(task_type_params)
      redirect_to roller_types_url,
                  success: 'Task type was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @task_type.destroy
    redirect_to roller_types_url,
                success: 'Task type was successfully destroyed.'
  end

  private

    def task_type_params
      params.require(:task_type).permit(:name, :icon, :color)
    end

    def authorize_task_type
      authorize TaskType
    end
end
