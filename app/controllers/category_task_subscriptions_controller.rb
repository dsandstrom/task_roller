# frozen_string_literal: true

class CategoryTaskSubscriptionsController < ApplicationController
  load_and_authorize_resource :category
  load_and_authorize_resource through: :category

  def new; end

  def create
    if @category_task_subscription.save
      redirect_back fallback_location: @category,
                    notice: 'Subscribed to Category Tasks'
    else
      render :new
    end
  end

  def destroy
    @category_task_subscription.destroy
    redirect_back fallback_location: @category,
                  notice: 'Unsubscribed from Category Tasks'
  end
end
