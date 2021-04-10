# frozen_string_literal: true

class IssueSubscriptionsController < ApplicationController
  load_and_authorize_resource :issue
  load_and_authorize_resource through: :issue

  def new; end

  def create
    if @issue_subscription.save
      create_success
    else
      create_failure
    end
  end

  def destroy
    @issue_subscription.destroy
    respond_to do |format|
      format.html do
        redirect_back fallback_location: @issue,
                      notice: "Unsubscribed from Issue ##{@issue.id}"
      end
      format.js { new_js }
    end
  end

  private

    def create_success
      notice = "Subscribed to Issue ##{@issue.id}. You will be notified after "\
               'updates.'
      respond_to do |format|
        format.html { redirect_back fallback_location: @issue, notice: notice }
        format.js { render :show }
      end
    end

    def create_failure
      respond_to do |format|
        format.html { render :new }
        format.js { new_js }
      end
    end

    def new_js
      @issue_subscription =
        @issue.issue_subscriptions.build(user_id: current_user.id)
      authorize! :create, @issue_subscription

      render :new
    end
end
