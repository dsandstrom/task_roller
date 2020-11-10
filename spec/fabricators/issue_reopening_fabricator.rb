# frozen_string_literal: true

Fabricator(:issue_reopening) do
  issue { Fabricate(:open_issue) }
  user { Fabricate(:user_reviewer) }
end
