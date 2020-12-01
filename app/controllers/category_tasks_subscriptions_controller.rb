# frozen_string_literal: true

class CategoryTasksSubscriptionsController < ApplicationController
  load_and_authorize_resource :category
  load_and_authorize_resource through: :category

  def new; end

  def create
    if @category_tasks_subscription.save
      redirect_back fallback_location: @category,
                    notice: "Subscribed to future tasks for #{@category.name}"
    else
      render :new
    end
  end

  def destroy
    notice = "No longer subscribed to future tasks for #{@category.name}"
    @category_tasks_subscription.destroy
    redirect_back fallback_location: @category, notice: notice
  end
end
