# frozen_string_literal: true

class ProjectsController < ApplicationController
  before_action :authorize_project, only: %i[index new create destroy]
  before_action :set_category, except: :index
  before_action :set_project, only: %i[show edit update destroy]

  def index
    @projects = Project.all
  end

  def show
    @issues = @project.issues.order(updated_at: :desc).limit(3)
    @tasks = @project.tasks.order(updated_at: :desc).limit(3)
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

  def destroy
    @project.destroy
    redirect_to category_path(@category),
                notice: 'Project was successfully destroyed.'
  end

  private

    def authorize_project
      authorize Project
    end

    def set_category
      @category = Category.find(params[:category_id])
    end

    def set_project
      @project = @category.projects.find(params[:id])
      authorize @project
    end

    def project_params
      params.require(:project).permit(:name, :visible, :internal)
    end
end
