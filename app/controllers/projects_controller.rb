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
    case params[:type]
    when 'issues'
      redirect_to project_issues_path(@project, params: filters)
    when 'tasks'
      redirect_to project_tasks_path(@project, params: filters)
    else
      @search_results = build_search_results.page(params[:page])
    end
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

    def filters
      @filters ||= build_filters.merge(project_ids: [@project.id])
    end

    def build_search_results
      SearchResult.accessible_by(current_ability)
                  .with_notifications(current_user, order_by: order_by)
                  .filter_by(filters)
                  .preload(:project, :user, :issue, :assignees,
                           project: :category)
    end

    def order_by
      @order_by ||= params[:order].blank? || params[:order] == 'updated,desc'
    end
end
