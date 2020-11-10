# frozen_string_literal: true

Fabricator(:task_reopening) do
  task { Fabricate(:open_task) }
  user { Fabricate(:user_reviewer) }
end
