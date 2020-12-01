# frozen_string_literal: true

class CategoryTasksSubscriptionsController < ApplicationController
  load_and_authorize_resource :category
  load_and_authorize_resource through: :category

  def new; end

  def create
    if @category_tasks_subscription.save
      redirect_back fallback_location: @category,
                    notice: 'Subscribed to new Category Tasks'
    else
      render :new
    end
  end

  def destroy
    @category_tasks_subscription.destroy
    redirect_back fallback_location: @category,
                  notice: 'Unsubscribed from new Category Tasks'
  end
end
