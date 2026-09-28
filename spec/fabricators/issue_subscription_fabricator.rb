Fabricator(:issue_subscription) do
  user
  issue
end

Fabricator(:inactive_issue_subscription, from: :issue_subscription) do
  active false
end
