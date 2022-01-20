# frozen_string_literal: true

# TODO: auto submit filters form on change
# TODO: should changing type, change form url

class CategoriesController < ApplicationController
  load_and_authorize_resource except: :archived

  def index
    @categories = @categories.all_visible
  end

  def archived
    authorize! :read, Category.new(visible: false)

    @categories = Category.all_invisible.accessible_by(current_ability)
  end

  def show
    @projects = @category.projects.all_visible.accessible_by(current_ability)

    case params[:type]
    when 'issues'
      redirect_to category_issues_path(@category, params: filters)
    when 'tasks'
      redirect_to category_tasks_path(@category, params: filters)
    else
      @search_results = build_search_results.page(params[:page])
    end
  end

  def new; end

  def edit; end

  def create
    if @category.save
      redirect_to @category, notice: 'Category was successfully created.'
    else
      render :new
    end
  end

  def update
    if @category.update(category_params)
      redirect_to redirect_url, notice: 'Category was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @category.destroy
    redirect_to root_url, notice: 'Category was successfully destroyed.'
  end

  private

    def category_params
      params.require(:category).permit(:name, :visible, :internal)
    end

    def filters
      @filters ||= build_filters.merge(project_ids: @projects.map(&:id))
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

    def redirect_url
      @redirect_url ||=
        if @category.visible?
          root_url
        else
          archived_categories_url
        end
    end
end
