# frozen_string_literal: true

class ReviewsController < ApplicationController
  load_and_authorize_resource :task
  load_and_authorize_resource through: :task

  def new; end

  def edit; end

  def create
    if @review.save
      @task.finish
      @task.update_status
      redirect_back fallback_location: @task,
                    notice: 'Review was successfully created.'
    else
      render :new
    end
  end

  def destroy
    @review.destroy
    @task.update_status
    redirect_back fallback_location: @task,
                  notice: 'Review was successfully destroyed.'
  end

  def approve
    if @review.approve(current_user)
      @review.subscribe_user
      redirect_back fallback_location: @task,
                    notice: 'Review was successfully updated.'
    else
      render :edit
    end
  end

  def disapprove
    if @review.disapprove(current_user)
      @review.subscribe_user
      redirect_back fallback_location: @task,
                    notice: 'Review was successfully updated.'
    else
      render :edit
    end
  end
end
