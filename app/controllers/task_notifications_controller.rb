# frozen_string_literal: true

class TaskNotificationsController < ApplicationController
  load_and_authorize_resource

  def destroy
    notice = 'Notification was successfully dismissed.'
    @task_notification.destroy
    redirect_back fallback_location: @task_notification.task, notice: notice
  end
end
