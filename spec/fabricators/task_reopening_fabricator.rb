Fabricator(:task_reopening) do
  task { Fabricate(:unassigned_task) }
  user { Fabricate(:user_reviewer) }
end
