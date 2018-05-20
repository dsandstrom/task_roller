# frozen_string_literal: true

Fabricator(:task_assignee) do
  task
  assignee { Fabricate(:user_worker) }
end
