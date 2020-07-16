# frozen_string_literal: true

Fabricator(:task) do
  summary { sequence(:issues) { |n| "Task Summary #{n + 1}" } }
  description 'Task Description'
  task_type
  user
  project
end

Fabricator(:open_task, from: :task) do
  closed false
end

Fabricator(:closed_task, from: :task) do
  closed true
end

Fabricator(:pending_task, from: :task) do
  closed false
end

Fabricator(:approved_task, from: :task) do
  closed true

  after_create do |task|
    Fabricate(:approved_review, task: task)
  end
end

Fabricator(:disapproved_task, from: :task) do
  closed true

  after_create do |task|
    Fabricate(:disapproved_review, task: task)
  end
end
