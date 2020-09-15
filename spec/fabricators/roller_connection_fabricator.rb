# frozen_string_literal: true

Fabricator(:issue_connection) do
  source { Fabricate(:issue) }
  target { Fabricate(:issue) }
end

Fabricator(:task_connection) do
  source { Fabricate(:task) }
  target { Fabricate(:task) }
end
