class ReviewsController < ApplicationController
  load_and_authorize_resource :task
  load_and_authorize_resource through: :task

  def new; end

  def edit; end

  def create
    if @review.save
      @task.finish?
      @task.update_status
      redirect_back_or_to(@task, notice: 'Task marked ready for review.')
    else
      render :new
    end
  end

  def destroy
    @review.destroy
    @task.update_status
    redirect_back_or_to(@task, notice: 'Review was canceled.')
  end

  def approve
    if @review.approve(current_user)
      @review.subscribe_user
      redirect_back_or_to(@task, notice: 'Task was approved.')
    else
      render :edit
    end
  end

  def disapprove
    if @review.disapprove(current_user)
      @review.subscribe_user
      redirect_back_or_to(@task, notice: 'Task was disapproved.')
    else
      render :edit
    end
  end
end
