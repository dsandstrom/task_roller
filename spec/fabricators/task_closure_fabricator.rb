# frozen_string_literal: true

Fabricator(:task_closure) do
  task { Fabricate(:closed_task) }
  user { Fabricate(:user_reviewer) }
end
