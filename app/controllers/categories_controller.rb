# frozen_string_literal: true

class CategoriesController < ApplicationController
  before_action :authorize_category, only: %i[index new create]
  before_action :set_category, only: %i[show edit update destroy]

  def index
    @categories = Category.all
  end

  def show
    @projects = @category.projects
    @issues = @category.issues.order(updated_at: :desc).limit(3)
    @tasks = @category.tasks.order(updated_at: :desc).limit(3)
  end

  def new
    @category = Category.new
  end

  def edit; end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to @category, notice: 'Category was successfully created.'
    else
      render :new
    end
  end

  def update
    if @category.update(category_params)
      redirect_to @category, notice: 'Category was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_url, notice: 'Category was successfully destroyed.'
  end

  private

    def set_category
      @category = authorize(Category.find(params[:id]))
    end

    def category_params
      params.require(:category).permit(:name, :visible, :internal)
    end

    def authorize_category
      authorize Category
    end
end
