class SubscriptionsController < ApplicationController
  authorize_resource :issue_subscription

  def index
    @subscriptions = build_subscriptions.filter_by(filters).page(params[:page])
  end

  private

    def filters
      @filters ||= build_filters
    end

    def build_subscriptions
      case filters[:type]
      when 'issues'
        build_issue_subscriptions
      when 'tasks'
        build_task_subscriptions
      else
        build_all_subscriptions
      end
    end

    def build_issue_subscriptions
      current_user.subscribed_issues_with_notifications(order_by: order_by)
                  .all_visible
                  .accessible_by(current_ability)
    end

    def build_task_subscriptions
      current_user.subscribed_tasks_with_notifications(order_by: order_by)
                  .all_visible
                  .accessible_by(current_ability)
    end

    def build_all_subscriptions
      current_user.subscriptions_with_notifications(order_by: order_by)
                  .all_visible
                  .accessible_by(current_ability, :index, strategy: :left_join)
    end
end
