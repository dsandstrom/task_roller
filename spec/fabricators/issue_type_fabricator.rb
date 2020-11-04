# frozen_string_literal: true

Fabricator(:issue_type) do
  name { sequence(:issue_types) { |n| "Issue Type #{n + 1}" } }
  icon  { IssueType::ICON_OPTIONS.sample }
  color { IssueType::COLOR_OPTIONS.sample }
end
