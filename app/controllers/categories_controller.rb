# frozen_string_literal: true

class CategoriesController < ApplicationController
  load_and_authorize_resource

  def index; end

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
