class TaskNotificationsRemovalJob < ApplicationJob
  queue_as :low_priority

  def perform(task, user)
    TaskNotification.where(task: task, user: user).destroy_all
  end
end
