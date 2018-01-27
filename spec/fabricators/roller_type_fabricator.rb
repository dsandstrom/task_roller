# frozen_string_literal: true

Fabricator(:issue_type) do
  name { sequence(:issue_types) { |n| "Issue Type #{n + 1}" } }
  icon  'icon'
  color 'color'
end

Fabricator(:task_type) do
  name { sequence(:task_types) { |n| "Task Type #{n + 1}" } }
  icon  'icon'
  color 'color'
end
