# frozen_string_literal: true

Fabricator(:task_type) do
  name { sequence(:task_types) { |n| "Task Type #{n + 1}" } }
  icon  { TaskType::ICON_OPTIONS.sample }
  color { TaskType::COLOR_OPTIONS.sample }
end
