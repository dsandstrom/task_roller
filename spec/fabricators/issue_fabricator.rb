# frozen_string_literal: true

Fabricator(:issue) do
  summary { sequence(:issues) { |n| "Issue Summary #{n + 1}" } }
  description 'Issue Description'
  issue_type
  user
  project
end
