# frozen_string_literal: true

class IssueNotificationsController < ApplicationController
  NOTICE = 'Notification was successfully dismissed.'

  load_and_authorize_resource

  # TODO: allow bulk destroy for issue/task
  def destroy
    @destroyed_id = @issue_notification.id
    @issue = @issue_notification.issue
    @issue_comment = @issue_notification.issue_comment
    @issue_notification.destroy

    respond_to do |format|
      format.html do
        redirect_back fallback_location: @issue, notice: NOTICE
      end
      format.js
    end
  end
end
