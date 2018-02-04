# frozen_string_literal: true

class ProjectsController < ApplicationController
  # TODO: restrict to category reviewers
  before_action :set_category, except: :index
  before_action :set_project, only: %i[show edit update destroy]

  # TODO: restrict to admins
  def index
    @projects = Project.all
  end

  def show
    @issues = @project.issues.order(updated_at: :desc).limit(3)
  end

  def new
    @project = @category.projects.build
  end

  def edit; end

  def create
    @project = @category.projects.build(project_params)

    if @project.save
      redirect_to category_project_path(@category, @project),
                  notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  def update
    if @project.update(project_params)
      redirect_to category_project_path(@category, @project),
                  notice: 'Project was successfully updated.'
    else
      render :edit
    end
  end

  # TODO: restrict to admins
  def destroy
    @project.destroy
    redirect_to category_path(@category),
                notice: 'Project was successfully destroyed.'
  end

  private

    def set_category
      @category = Category.find(params[:category_id])
    end

    def set_project
      @project = @category.projects.find(params[:id])
    end

    def project_params
      params.require(:project).permit(:name, :visible, :internal)
    end
end
