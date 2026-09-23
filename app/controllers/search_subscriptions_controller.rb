class SearchSubscriptionsController < ApplicationController
  load_and_authorize_resource through: :current_user, except: :create
  before_action :find_or_initialize, only: :create

  def index; end

  def show
    @search_results =
      @search_subscription.search_results
                          .accessible_by(current_ability, :index,
                                         strategy: :left_join)
                          .page(params[:page])
  end

  # TODO: remove new?
  def new; end

  def create
    if @search_subscription.persisted? && !@search_subscription.active
      @search_subscription.toggle
    end

    if @search_subscription.save
      redirect_to @search_subscription
    else
      render :new
    end
  end

  def toggle
    @search_subscription.toggle

    redirect_to search_subscriptions_url
  end

  def destroy
    @search_subscription.destroy
    redirect_to search_subscriptions_url
  end

  private

    def search_subscription_params
      normalize_search_subscription_params

      params.expect(
        search_subscription: %i[term include_issues include_tasks issue_type_id
                                task_type_id issue_status task_status
                                source_user_id category_id project_id]
      )
    end

    def normalize_search_subscription_params
      params[:search_subscription].each do |key, val|
        params[:search_subscription][key] = nil if val.blank?
      end
    end

    def find_or_initialize
      @search_subscription =
        current_user.search_subscriptions
                    .find_or_initialize_by(search_subscription_params)
      authorize! :create, @search_subscription
    end
end
