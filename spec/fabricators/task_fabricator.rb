# frozen_string_literal: true

Fabricator(:task) do
  summary { sequence(:issues) { |n| "Task Summary #{n + 1}" } }
  description 'Task Description'
  task_type
  user
  project
end
