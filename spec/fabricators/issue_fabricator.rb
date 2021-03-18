# frozen_string_literal: true

Fabricator(:issue) do
  summary { sequence(:issues) { |n| "Issue Summary #{n + 1}" } }
  description 'Issue Description'
  issue_type
  user
  project
  status 'open'
end

Fabricator(:open_issue, from: :issue) do
  closed false
  status 'open'
end

Fabricator(:closed_issue, from: :issue) do
  closed true
  status 'closed'
end

Fabricator(:being_worked_on_issue, from: :open_issue) do
  status 'being_worked_on'

  after_create do |issue|
    return if issue.tasks.any?

    Fabricate(:task, issue: issue)
  end
end

Fabricator(:addressed_issue, from: :closed_issue) do
  status 'addressed'

  after_create do |issue|
    return if issue.tasks.any?

    Fabricate(:approved_task, issue: issue)
  end
end

Fabricator(:duplicate_issue, from: :closed_issue) do
  status 'duplicate'

  after_create do |issue|
    return if issue.source_connection

    Fabricate(:issue_connection, source: issue)
  end
end

Fabricator(:resolved_issue, from: :closed_issue) do
  status 'resolved'

  after_create do |issue|
    return if issue.current_resolution

    Fabricate(:approved_resolution, issue: issue)
  end
end
