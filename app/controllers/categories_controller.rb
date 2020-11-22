# frozen_string_literal: true

class CategoriesController < ApplicationController
  load_and_authorize_resource except: :archived

  # TODO: show categories with invisible projects?
  def index
    @categories = @categories.all_visible
  end

  def archived
    authorize! :read, Category.new(visible: false)

    @categories = Category.all_invisible.accessible_by(current_ability)
  end

  def new; end

  def edit; end

  def create
    if @category.save
      redirect_to category_projects_url(@category),
                  notice: 'Category was successfully created.'
    else
      render :new
    end
  end

  def update
    if @category.update(category_params)
      redirect_to categories_url, notice: 'Category was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_url, notice: 'Category was successfully destroyed.'
  end

  private

    def category_params
      params.require(:category).permit(:name, :visible, :internal)
    end
end
