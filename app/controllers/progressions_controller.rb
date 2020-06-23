# frozen_string_literal: true

class ProgressionsController < ApplicationController
  before_action :set_task
  before_action :set_progression, only: %i[edit update destroy]

  def index
    @progressions = @task.progressions.order(created_at: :asc)
  end

  def new
    @progression = @task.progressions.build
  end

  def edit
  end

  def create
    @progression = @task.progressions.build(progression_params)

    if @progression.save
      redirect_to category_project_task_path(@category, @project, @task),
                  notice: 'Progress successfully started on task.'
    else
      render :new
    end
  end

  def update
    if @progression.update(progression_params)
      redirect_to category_project_task_path(@category, @project, @task),
                  notice: 'Progress was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @progression.destroy
    redirect_to category_project_task_path(@category, @project, @task),
                notice: 'Progression was successfully destroyed.'
  end

  private

    # TODO: authorize access
    def set_task
      @task = Task.find(params[:task_id])
      @project = @task.project
      @category = @task.category
      raise ActiveRecord::RecordNotFound unless @category
    end

    def set_progression
      @progression = @task.progressions.find(params[:id])
    end

    def progression_params
      params.require(:progression).permit(:task_id, :user_id, :finished)
    end
end
