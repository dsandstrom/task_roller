# frozen_string_literal: true

class ReviewsController < ApplicationController
  before_action :set_task
  before_action :set_review, only: %i[show edit update destroy]

  def index
    @reviews = @task.reviews
  end

  def new
    @review = @task.reviews.build
  end

  def edit
  end

  def create
    @review = @task.reviews.build(review_params)

    if @review.save
      redirect_to category_project_task_path(@category, @project, @task),
                  notice: 'Review was successfully created.'
    else
      render :new
    end
  end

  def update
    if @review.update(review_params)
      redirect_to category_project_task_path(@category, @project, @task),
                  notice: 'Review was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @review.destroy
    redirect_to category_project_task_path(@category, @project, @task),
                notice: 'Review was successfully destroyed.'
  end

  private

    def set_review
      @review = @task.reviews.find(params[:id])
    end

    def review_params
      params.require(:review).permit(:user_id, :approved)
    end

    # TODO: authorize access
    def set_task
      @task = Task.find(params[:task_id])
      @project = @task.project
      @category = @task.category
      raise ActiveRecord::RecordNotFound unless @category
    end
end
