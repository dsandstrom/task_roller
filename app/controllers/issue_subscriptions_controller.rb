# TODO: remove all js responses after done with turbfying

class IssueSubscriptionsController < ApplicationController
  load_and_authorize_resource :issue
  load_and_authorize_resource through: :issue

  def new; end

  def create
    if @issue_subscription.save
      respond_to do |format|
        format.html do
          redirect_back_or_to(@issue, notice: create_notice)
        end
        format.turbo_stream { redirect_back_or_to(@issue) }
      end
    else
      render :new
    end
  end

  def destroy
    @issue_subscription.destroy

    respond_to do |format|
      format.html do
        redirect_back_or_to(@issue, notice: destroy_notice)
      end
      format.turbo_stream { redirect_back_or_to(@issue) }
    end
  end

  private

    def create_notice
      "Subscribed to Issue ##{@issue.id}. You will be notified after updates."
    end

    def destroy_notice
      "Unsubscribed from Issue ##{@issue.id}"
    end
end
