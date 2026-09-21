class SearchSubscriptionsController < ApplicationController
  load_and_authorize_resource through: :current_user

  def index; end

  def show; end

  def new; end

  def edit; end

  def create
    if @search_subscription.save
      redirect_to search_subscriptions_url
    else
      render :new
    end
  end

  def update
    if @search_subscription.update(search_subscription_params)
      redirect_to search_subscriptions_url
    else
      render :edit
    end
  end

  def destroy
    @search_subscription.destroy
    redirect_to search_subscriptions_url
  end

  private

    def search_subscription_params
      params.expect(
        search_subscription: %i[term include_issues include_tasks issue_type_id
                                task_type_id status source_user_id category_id
                                project_id]
      )
    end
end
