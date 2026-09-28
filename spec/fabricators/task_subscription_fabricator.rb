Fabricator(:task_subscription) do
  user
  task
end

Fabricator(:inactive_task_subscription, from: :task_subscription) do
  active false
end
