# frozen_string_literal: true

class ProjectsController < ApplicationController
  load_and_authorize_resource :category, except: %i[show edit update]
  load_and_authorize_resource through: :category, except: %i[show edit update]
  load_and_authorize_resource only: %i[show edit update]

  load_resource :issues, through: :category, only: :index, singleton: true
  load_resource :tasks, through: :category, only: :index, singleton: true

  def index
    @issues = @issues.accessible_by(current_ability)
                     .order(updated_at: :desc).limit(3)
    @tasks = @tasks.accessible_by(current_ability)
                   .order(updated_at: :desc).limit(3)
    @issue_subscription =
      @category.category_issues_subscriptions
               .find_or_initialize_by(user_id: current_user.id)
    @task_subscription =
      @category.category_tasks_subscriptions
               .find_or_initialize_by(user_id: current_user.id)
  end

  def show
    @issues = @project.issues.order(updated_at: :desc).limit(3)
    @tasks = @project.tasks.order(updated_at: :desc).limit(3)
    @issue_subscription =
      @project.project_issues_subscriptions
              .find_or_initialize_by(user_id: current_user.id)
    @task_subscription =
      @project.project_tasks_subscriptions
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
    @project.destroy
    redirect_to category_projects_url(@category),
                notice: 'Project was successfully destroyed.'
  end

  private

    def project_params
      params.require(:project).permit(:category_id, :name, :visible, :internal)
    end
end
