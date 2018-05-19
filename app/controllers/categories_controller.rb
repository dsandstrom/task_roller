# frozen_string_literal: true

class CategoriesController < ApplicationController
  # TODO: restrict to reviewers
  before_action :set_category, only: %i[show edit update destroy]

  # TODO: just reviewer categories
  def index
    @categories = Category.all
  end

  # TODO: restrict to category reviewers
  def show
    @projects = @category.projects
    @issues = @category.issues.order(updated_at: :desc).limit(3)
    @tasks = @category.tasks.order(updated_at: :desc).limit(3)
  end

  # TODO: restrict to admins
  def new
    @category = Category.new
  end

  # TODO: restrict to category reviewers
  def edit; end

  # TODO: restrict to admins
  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to @category, notice: 'Category was successfully created.'
    else
      render :new
    end
  end

  # TODO: restrict to category reviewers
  def update
    if @category.update(category_params)
      redirect_to @category, notice: 'Category was successfully updated.'
    else
      render :edit
    end
  end

  # TODO: restrict to admins
  def destroy
    @category.destroy
    redirect_to categories_url, notice: 'Category was successfully destroyed.'
  end

  private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :visible, :internal)
    end
end
