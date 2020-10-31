# frozen_string_literal: true

class ReviewsController < ApplicationController
  load_and_authorize_resource :task
  load_and_authorize_resource through: :task

  def new; end

  def edit; end

  def create
    if @review.save
      @task.finish
      redirect_to @task, notice: 'Review was successfully created.'
    else
      render :new
    end
  end

  def destroy
    @review.destroy
    redirect_to @task, notice: 'Review was successfully destroyed.'
  end

  def approve
    if @review.approve(current_user)
      redirect_to @task, notice: 'Review was successfully updated.'
    else
      render :edit
    end
  end

  def disapprove
    if @review.disapprove(current_user)
      redirect_to @task, notice: 'Review was successfully updated.'
    else
      render :edit
    end
  end
end
