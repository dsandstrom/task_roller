# frozen_string_literal: true

class TaskTypesController < ApplicationController
  load_and_authorize_resource

  def new; end

  def edit; end

  def create
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
end
