# frozen_string_literal: true

# TODO: add js create/destroy response and partials

class IssueSubscriptionsController < ApplicationController
  before_action :authorize_issue_subscription, only: %i[index new create]
  before_action :set_issue, only: %i[new create]
  before_action :build_issue_subscription, only: %i[new create]
  before_action :set_issue_subscription, only: %i[show edit update destroy]

  def index
    @issues = current_user.subscribed_issues.filter_by(build_filters)
                          .page(params[:page])
  end

  def new
  end

  def create
    if @issue_subscription.save
      redirect_to @issue, notice: 'Subscribed to Issue'
    else
      render :new
    end
  end

  def destroy
    @issue_subscription.destroy
    redirect_to @issue, notice: 'Unsubscribed from Issue'
  end

  private

    def authorize_issue_subscription
      authorize IssueSubscription
    end

    def set_issue
      @issue = Issue.find(params[:issue_id])
    end

    def set_issue_subscription
      @issue_subscription = authorize(IssueSubscription.find(params[:id]))
      @issue = @issue_subscription.issue
    end

    def build_issue_subscription
      @issue_subscription =
        @issue.issue_subscriptions.build(user_id: current_user.id)
    end
end
