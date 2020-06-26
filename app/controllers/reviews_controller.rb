# frozen_string_literal: true

class ReviewsController < ApplicationController
  before_action :set_task
  before_action :set_review, except: %i[index new create]

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
      @task.finish
      redirect_to category_project_task_path(@category, @project, @task),
                  notice: 'Review was successfully created.'
    else
      render :new
    end
  end

  def approve
    if @review.approve
      redirect_to category_project_task_path(@category, @project, @task),
                  notice: 'Review was successfully updated.'
    else
      render :edit
    end
  end

  def disapprove
    if @review.disapprove
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
      params.require(:review).permit(:user_id)
    end

    # TODO: authorize access
    def set_task
      @task = Task.find(params[:task_id])
      @project = @task.project
      @category = @task.category
      raise ActiveRecord::RecordNotFound unless @category
    end
end
