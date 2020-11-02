# frozen_string_literal: true

Fabricator(:project_issue_subscription) do
  project
  user
end

Fabricator(:project_task_subscription) do
  project
  user
end
