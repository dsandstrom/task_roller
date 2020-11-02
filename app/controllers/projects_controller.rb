# frozen_string_literal: true

class ProjectsController < ApplicationController
  load_and_authorize_resource only: %i[index show edit update destroy]
  load_and_authorize_resource :category, only: %i[new create]
  load_and_authorize_resource through: :category, only: %i[new create]

  def show
    @issues = @project.issues.order(updated_at: :desc).limit(3)
    @tasks = @project.tasks.order(updated_at: :desc).limit(3)
    @issue_subscription =
      @project.project_issue_subscriptions
              .find_or_initialize_by(user_id: current_user.id)
    @task_subscription =
      @project.project_task_subscriptions
              .find_or_initialize_by(user_id: current_user.id)
  end

  def new; end

  def edit; end

  def create
    if @project.save
      redirect_to @project, notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    category = @project.category
    @project.destroy
    redirect_to category, notice: 'Project was successfully destroyed.'
  end

  private

    def project_params
      params.require(:project).permit(:name, :visible, :internal)
    end
end
