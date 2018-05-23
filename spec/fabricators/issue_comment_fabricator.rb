# frozen_string_literal: true

Fabricator(:issue_comment) do
  issue
  user
  body 'Issue Comment Body'
end
