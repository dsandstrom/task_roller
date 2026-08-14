Fabricator(:issue) do
  summary { sequence(:issues) { |n| "Issue Summary #{n + 1}" } }
  description 'Issue Description'
  issue_type
  user
  project
  status 'pending'
end

Fabricator(:pending_issue, from: :issue, aliases: %i[open_issue]) do
  closed false
  status 'pending'
end

Fabricator(:being_worked_on_issue, from: :issue) do
  closed false
  status 'being_worked_on'

  after_create do |issue|
    return if issue.tasks.any?

    Fabricate(:task, issue: issue)
  end
end

Fabricator(:addressed_issue, from: :issue) do
  closed true
  status 'addressed'

  after_create do |issue|
    return if issue.tasks.any?

    Fabricate(:approved_task, issue: issue)
  end
end

Fabricator(:duplicate_issue, from: :issue) do
  transient :target

  closed true
  status 'duplicate'

  before_create do |issue, transients|
    issue.project ||= transients[:target]&.project || Fabricate(:project)
  end

  after_create do |issue, transients|
    next if issue.source_connection

    transients[:target] ||= Fabricate(:addressed_issue, project: issue.project)
    Fabricate(:issue_connection, source: issue, target: transients[:target])
  end
end

Fabricator(:resolved_issue, from: :issue, aliases: %i[closed_issue]) do
  closed true
  status 'resolved'

  after_create do |issue|
    return if issue.current_resolution

    Fabricate(:approved_resolution, issue: issue)
  end
end
