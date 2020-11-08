# frozen_string_literal: true

# TODO: add js create/destroy response and partials

class IssueSubscriptionsController < ApplicationController
  authorize_resource only: :index
  load_and_authorize_resource :issue, except: :index
  load_and_authorize_resource through: :issue, except: :index

  def index
    @subscribed_issues =
      current_user.subscribed_issues.filter_by(build_filters)
                  .page(params[:page])
  end

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
