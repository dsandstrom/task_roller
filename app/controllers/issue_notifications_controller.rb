# frozen_string_literal: true

class IssueNotificationsController < ApplicationController
  load_and_authorize_resource :issue, only: :bulk_destroy
  load_and_authorize_resource only: :destroy

  def destroy
    cache_resources
    @issue_notification.destroy

    respond_to do |format|
      format.html do
        redirect_back fallback_location: @issue,
                      notice: 'Notification was successfully dismissed.'
      end
      format.js
    end
  end

  def bulk_destroy
    @issue.notifications.where(user_id: current_user_id).destroy_all

    respond_to do |format|
      format.html do
        redirect_back fallback_location: @issue,
                      notice: 'Notifications were successfully dismissed.'
      end
      format.js
    end
  end

  private

    def cache_resources
      @destroyed_id = @issue_notification.id
      @issue = @issue_notification.issue
      @issue_comment = @issue_notification.issue_comment
    end
end
