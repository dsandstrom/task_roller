# frozen_string_literal: true

Fabricator(:issue_closure) do
  issue
  user { Fabricate(:user_reviewer) }
end
