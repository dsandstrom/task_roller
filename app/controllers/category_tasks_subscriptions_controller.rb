# frozen_string_literal: true

class CategoryTasksSubscriptionsController < ApplicationController
  load_and_authorize_resource :category
  load_and_authorize_resource through: :category

  def new; end

  def create
    if @category_tasks_subscription.save
      create_success
    else
      create_failure
    end
  end

  def destroy
    notice = "No longer subscribed to future tasks for #{@category.name}"
    @category_tasks_subscription.destroy
    respond_to do |format|
      format.html { redirect_back fallback_location: @category, notice: notice }
      format.js { new_js }
    end
  end

  private

    def create_success
      notice = "Subscribed to future tasks for #{@category.name}"
      respond_to do |format|
        format.html do
          redirect_back fallback_location: @category, notice: notice
        end
        format.js { render :show }
      end
    end

    def create_failure
      respond_to do |format|
        format.html { render :new }
        format.js { new_js }
      end
    end

    def new_js
      @category_tasks_subscription =
        @category.category_tasks_subscriptions.build(user_id: current_user_id)
      authorize! :create, @category_tasks_subscription

      render :new
    end
end
