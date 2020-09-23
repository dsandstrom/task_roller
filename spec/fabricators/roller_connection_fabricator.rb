# frozen_string_literal: true

Fabricator(:issue_connection) do
  source { Fabricate(:issue) }
  target { |attrs| Fabricate(:issue, project: attrs[:source].project) }
end

Fabricator(:task_connection) do
  source { Fabricate(:task) }
  target { |attrs| Fabricate(:task, project: attrs[:source].project) }
end
