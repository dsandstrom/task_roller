# frozen_string_literal: true

Fabricator(:issue_notification) do
  issue
  user
  event 'new'
end
