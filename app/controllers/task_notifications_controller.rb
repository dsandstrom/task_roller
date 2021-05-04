# frozen_string_literal: true

class TaskNotificationsController < ApplicationController
  load_and_authorize_resource :task, only: :bulk_destroy
  load_and_authorize_resource only: :destroy

  def destroy
    cache_resources
    @task_notification.destroy

    respond_to do |format|
      format.html do
        redirect_back fallback_location: @task,
                      notice: 'Notification was successfully dismissed.'
      end
      format.js
    end
  end

  def bulk_destroy
    @task.notifications.where(user_id: current_user_id).destroy_all

    respond_to do |format|
      format.html do
        redirect_back fallback_location: @task,
                      notice: 'Notifications were successfully dismissed.'
      end
      format.js
    end
  end

  private

    def cache_resources
      @destroyed_id = @task_notification.id
      @task = @task_notification.task
      @task_comment = @task_notification.task_comment
    end
end
