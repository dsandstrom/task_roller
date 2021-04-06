# frozen_string_literal: true

class IssueSubscriptionsController < ApplicationController
  load_and_authorize_resource :issue
  load_and_authorize_resource through: :issue

  def new; end

  def create
    if @issue_subscription.save
      notice = "Subscribed to Issue ##{@issue.id}. You will be notified after "\
               'updates.'
      redirect_back fallback_location: @issue, notice: notice
    else
      render :new
    end
  end

  def destroy
    @issue_subscription.destroy
    redirect_back fallback_location: @issue,
                  notice: "Unsubscribed from Issue ##{@issue.id}"
  end
end
