Fabricator(:task_closure) do
  task { Fabricate(:duplicate_task) }
  user { Fabricate(:user_reviewer) }
end
