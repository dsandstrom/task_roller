# frozen_string_literal: true

class ReviewsController < ApplicationController
  before_action :set_task
  before_action :set_review, except: %i[index new create]

  def index
    @reviews = @task.reviews
  end

  def new
    @review = authorize(@task.reviews.build(user_id: current_user.id))
  end

  def edit
  end

  def create
    @review = authorize(@task.reviews.build(user_id: current_user.id))

    if @review.save
      @task.finish
      redirect_to task_path(@task),
                  notice: 'Review was successfully created.'
    else
      render :new
    end
  end

  def destroy
    @review.destroy
    redirect_to task_path(@task),
                notice: 'Review was successfully destroyed.'
  end

  def approve
    if @review.approve
      redirect_to task_path(@task),
                  notice: 'Review was successfully updated.'
    else
      render :edit
    end
  end

  def disapprove
    if @review.disapprove
      redirect_to task_path(@task),
                  notice: 'Review was successfully updated.'
    else
      render :edit
    end
  end

  private

    def set_review
      @review = authorize(@task.reviews.find(params[:id]))
      @review.user_id = current_user.id
    end

    def set_task
      @task = Task.find(params[:task_id])
      @project = @task.project
      @category = @task.category
      raise ActiveRecord::RecordNotFound unless @category
    end
end
