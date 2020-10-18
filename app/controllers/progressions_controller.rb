# frozen_string_literal: true

class ProgressionsController < ApplicationController
  before_action :authorize_progression, only: %i[index destroy]
  before_action :set_task
  before_action :set_progression, only: %i[edit update destroy finish]

  # TODO: remove action, use task show/history
  def index
    @progressions = @task.progressions.order(created_at: :asc)
  end

  def new
    @progression = @task.progressions.build
    authorize @progression
  end

  def edit
  end

  def create
    @progression = @task.progressions.build(user_id: current_user.id)
    authorize @progression

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

  def finish
    if @progression.finish
      redirect_to category_project_task_path(@category, @project, @task),
                  notice: 'Progress was successfully finished.'
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

    def authorize_progression
      authorize Progression
    end

    def set_task
      @task = Task.find(params[:task_id])
      @project = @task.project
      @category = @task.category
      raise ActiveRecord::RecordNotFound unless @category
    end

    def set_progression
      @progression = @task.progressions.find(params[:id])
      authorize @progression
    end

    def progression_params
      params.require(:progression).permit(:user_id, :finished)
    end
end
