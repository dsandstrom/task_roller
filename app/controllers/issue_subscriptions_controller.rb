# frozen_string_literal: true

# TODO: add js create/destroy response and partials

class IssueSubscriptionsController < ApplicationController
  load_and_authorize_resource :issue
  load_and_authorize_resource through: :issue

  def new; end

  def create
    if @issue_subscription.save
      redirect_back fallback_location: @issue, notice: 'Subscribed to Issue'
    else
      render :new
    end
  end

  def destroy
    @issue_subscription.destroy
    redirect_back fallback_location: @issue, notice: 'Unsubscribed from Issue'
  end
end
