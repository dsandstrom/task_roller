# frozen_string_literal: true

Fabricator(:issue_notification) do
  issue
  user
  event 'new'
end

Fabricator(:issue_status_notification, from: :issue_notification) do
  event 'status'
  details 'open,being_worked_on'
end

Fabricator(:issue_new_notification, from: :issue_notification) do
  event 'new'
end

Fabricator(:issue_comment_notification, from: :issue_notification) do
  event 'comment'
  issue_comment
end
