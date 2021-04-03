# frozen_string_literal: true

class ProjectsController < ApplicationController
  load_and_authorize_resource :category, except: %i[show edit update]
  load_and_authorize_resource through: :category,
                              except: %i[archived show edit update]
  load_and_authorize_resource only: %i[show edit update]

  def index
    @projects = @projects.all_visible if @category.visible?
  end

  def archived
    authorize! :read, Project.new(visible: false)

    @projects = @category.projects.all_invisible.accessible_by(current_ability)
  end

  def show
    @issues = build_issues
    @tasks = build_tasks
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
    redirect_to @category, notice: 'Project was successfully destroyed.'
  end

  private

    def project_params
      params.require(:project).permit(:category_id, :name, :visible, :internal)
    end

    def build_issues
      if @category
        issues = @category.issues
        issues = issues.all_visible if @category.visible?
        issues.accessible_by(current_ability)
              .order(updated_at: :desc).limit(3)
      elsif @project
        @project.issues.accessible_by(current_ability)
                .order(updated_at: :desc).limit(3)
      end
    end

    def build_tasks
      if @category
        tasks = @category.tasks
        tasks = tasks.all_visible if @category.visible?
        tasks.accessible_by(current_ability).order(updated_at: :desc).limit(3)
      elsif @project
        @project.tasks.accessible_by(current_ability)
                .order(updated_at: :desc).limit(3)
      end
    end
end
