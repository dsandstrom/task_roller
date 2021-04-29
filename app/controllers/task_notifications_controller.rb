# frozen_string_literal: true

class TaskNotificationsController < ApplicationController
  NOTICE = 'Notification was successfully dismissed.'

  load_and_authorize_resource

  def destroy
    @destroyed_id = @task_notification.id
    @task = @task_notification.task
    @task_comment = @task_notification.task_comment
    @task_notification.destroy

    respond_to do |format|
      format.html do
        redirect_back fallback_location: @task, notice: NOTICE
      end
      format.js
    end
  end
end
