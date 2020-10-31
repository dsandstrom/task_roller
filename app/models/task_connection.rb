# frozen_string_literal: true

class TaskConnection < RollerConnection
  # current task
  belongs_to :source, class_name: 'Task'
  # task current task duplicates
  belongs_to :target, class_name: 'Task'

  def target_options
    @target_options ||=
      (source.project&.tasks&.where&.not(id: source.id) if source&.id)
  end

  def subscribe_user
    return unless target && source&.user

    target.task_subscriptions.create(user_id: source.user_id)
  end
end
