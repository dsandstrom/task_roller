class CategoryTasksSubscriptionsController < ApplicationController
  load_and_authorize_resource :category
  load_and_authorize_resource through: :category

  def new; end

  def create
    if @category_tasks_subscription.save
      respond_to do |format|
        format.html do
          redirect_back fallback_location: @category, notice: notice
        end
        format.turbo_stream { redirect_back fallback_location: @category }
      end
    else
      render :new
    end
  end

  def destroy
    @category_tasks_subscription.destroy

    respond_to do |format|
      format.html { redirect_back fallback_location: @category, notice: notice }
      format.turbo_stream { redirect_back fallback_location: @category }
    end
  end

  private

    def create_notice
      "Subscribed to future tasks for #{@category.name}"
    end

    def destroy_notice
      "No longer subscribed to future tasks for #{@category.name}"
    end
end
