# frozen_string_literal: true

Fabricator(:issue) do
  summary { sequence(:issues) { |n| "Issue Summary #{n + 1}" } }
  description 'Issue Description'
  issue_type
  user
  project
end

Fabricator(:open_issue, from: :issue) do
  closed false
end

Fabricator(:closed_issue, from: :issue) do
  closed true
end
