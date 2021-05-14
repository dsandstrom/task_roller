# frozen_string_literal: true

# TODO: show category & project subscriptions

class SubscriptionsController < ApplicationController
  authorize_resource :issue_subscription

  def index
    @subscriptions = build_subscriptions.all_visible
                                        .accessible_by(current_ability)
                                        .filter_by(filters).page(params[:page])
  end

  private

    def filters
      @filters ||= build_filters
    end

    def build_filters
      temp = super
      temp[:order] = 'count,desc' if temp[:order] == 'updated,desc'
      temp
    end

    def build_subscriptions
      case filters[:type]
      when 'issues'
        current_user.subscribed_issues_with_notifications(order_by: order_by)
      when 'tasks'
        current_user.subscribed_tasks_with_notifications(order_by: order_by)
      else
        current_user.subscriptions_with_notifications(order_by: order_by)
      end
    end

    def order_by
      @order_by ||= params[:order].blank? || params[:order] == 'updated,desc'
    end
end
