class CategoryIssuesSubscriptionsController < ApplicationController
  load_and_authorize_resource :category
  load_and_authorize_resource through: :category

  def new; end

  def create
    if @category_issues_subscription.save
      respond_to do |format|
        format.html do
          redirect_back_or_to(@category, notice: notice)
        end
        format.turbo_stream { redirect_back_or_to(@category) }
      end
    else
      render :new
    end
  end

  def destroy
    @category_issues_subscription.destroy

    respond_to do |format|
      format.html { redirect_back_or_to(@category, notice: notice) }
      format.turbo_stream { redirect_back_or_to(@category) }
    end
  end

  private

    def create_notice
      "Subscribed to future issues for #{@category.name}"
    end

    def destroy_notice
      "No longer subscribed to future issues for #{@category.name}"
    end
end
