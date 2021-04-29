# frozen_string_literal: true

class IssueNotificationsController < ApplicationController
  load_and_authorize_resource

  def destroy
    notice = 'Notification was successfully dismissed.'
    @issue_notification.destroy
    redirect_back fallback_location: @issue_notification.issue, notice: notice
  end
end
