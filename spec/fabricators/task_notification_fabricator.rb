Fabricator(:task_notification) do
  task
  user
  event 'new'
end

Fabricator(:task_status_notification, from: :task_notification) do
  event 'status'
  details 'unassigned,assigned'
end

Fabricator(:task_new_notification, from: :task_notification) do
  event 'new'
end

Fabricator(:task_comment_notification, from: :task_notification) do
  event 'comment'
  task_comment
end
