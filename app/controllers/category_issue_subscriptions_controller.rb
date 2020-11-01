# frozen_string_literal: true

class CategoryIssueSubscriptionsController < ApplicationController
  load_and_authorize_resource :category
  load_and_authorize_resource through: :category

  def new; end

  def create
    if @category_issue_subscription.save
      redirect_to @category, notice: 'Subscribed to Category Issues'
    else
      render :new
    end
  end

  def destroy
    @category_issue_subscription.destroy
    redirect_to @category, notice: 'Unsubscribed from Category Issues'
  end
end
