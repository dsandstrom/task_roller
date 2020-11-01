# frozen_string_literal: true

Fabricator(:category_issue_subscription) do
  category
  user
end

Fabricator(:category_task_subscription) do
  category
  user
end
