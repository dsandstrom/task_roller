# TODO: remove all js responses after done with turbfying

class IssueSubscriptionsController < ApplicationController
  load_and_authorize_resource :issue
  load_and_authorize_resource through: :issue

  def new; end

  def create
    if @issue_subscription.save
      notice = "Subscribed to Issue ##{@issue.id}. You will be notified " \
               'after updates.'
      respond_to do |format|
        format.html { redirect_back fallback_location: @issue, notice: notice }
        format.turbo_stream { redirect_back fallback_location: @issue }
      end
    else
      render :new
    end
  end

  def destroy
    @issue_subscription.destroy
    respond_to do |format|
      format.html do
        redirect_back fallback_location: @issue,
                      notice: "Unsubscribed from Issue ##{@issue.id}"
      end
      format.turbo_stream { redirect_back fallback_location: @issue }
    end
  end
end
