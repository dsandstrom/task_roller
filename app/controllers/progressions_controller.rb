# frozen_string_literal: true

class ProgressionsController < ApplicationController
  before_action :set_task
  before_action :set_progression, only: %i[edit update destroy finish]

  def index
    @progressions = @task.progressions.order(created_at: :asc)
  end

  # TODO: assigned to task
  def new
    @progression = @task.progressions.build
  end

  # TODO: admin
  def edit
  end

  # TODO: assigned to task
  def create
    # TODO: use current_user and create without params
    @progression = @task.progressions.build(progression_params)

    if @progression.save
      redirect_to category_project_task_path(@category, @project, @task),
                  notice: 'Progress successfully started on task.'
    else
      render :new
    end
  end

  # TODO: admin
  def update
    if @progression.update(progression_params)
      redirect_to category_project_task_path(@category, @project, @task),
                  notice: 'Progress was successfully updated.'
    else
      render :edit
    end
  end

  # TODO: user and admin
  def finish
    if @progression.finish
      redirect_to category_project_task_path(@category, @project, @task),
                  notice: 'Progress was successfully finished.'
    else
      render :edit
    end
  end

  # TODO: admin
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
      params.require(:progression).permit(:user_id, :finished)
    end
end
