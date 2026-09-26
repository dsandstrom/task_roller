class SearchSubscriptionsController < ApplicationController
  load_and_authorize_resource through: :current_user, except: :create
  before_action :find_or_initialize, only: :create

  def index; end

  def show
    redirect_to search_subscription_path_to_source
  end

  # TODO: remove new?
  def new; end

  def create
    if @search_subscription.persisted? && !@search_subscription.active
      @search_subscription.toggle
    end

    if @search_subscription.save
      redirect_to search_subscriptions_url
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
        # rubocop:disable Rails/StrongParametersExpect
        params[:search_subscription][key] = nil if val.blank?
        # rubocop:enable Rails/StrongParametersExpect
      end
    end

    def find_or_initialize
      @search_subscription =
        current_user.search_subscriptions
                    .find_or_initialize_by(search_subscription_params)
      authorize! :create, @search_subscription
    end

    def filter_params
      @search_subscription.filter_params
    end

    def search_subscription_path_to_source
      if @search_subscription.source_user
        search_subscription_path_to_user
      elsif @search_subscription.category
        search_subscription_path_to_category
      elsif @search_subscription.project
        search_subscription_path_to_project
      else
        search_results_url(filter_params)
      end
    end

    def search_subscription_path_to_user
      if @search_subscription.include_issues
        user_issues_url(@search_subscription.source_user, filter_params)
      else
        user_tasks_url(@search_subscription.source_user, filter_params)
      end
    end

    def search_subscription_path_to_category
      if @search_subscription.include_issues &&
         @search_subscription.include_tasks
        category_url(@search_subscription.category, filter_params)
      elsif @search_subscription.include_issues
        category_issues_url(@search_subscription.category, filter_params)
      else
        category_tasks_url(@search_subscription.category, filter_params)
      end
    end

    def search_subscription_path_to_project
      if @search_subscription.include_issues &&
         @search_subscription.include_tasks
        project_url(@search_subscription.project, filter_params)
      elsif @search_subscription.include_issues
        project_issues_url(@search_subscription.project, filter_params)
      else
        project_tasks_url(@search_subscription.project, filter_params)
      end
    end
end
