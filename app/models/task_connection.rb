# frozen_string_literal: true

class TaskConnection < RollerConnection
  # current task
  belongs_to :source, class_name: 'Task'
  # task current task duplicates
  belongs_to :target, class_name: 'Task'
end
