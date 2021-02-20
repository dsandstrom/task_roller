# frozen_string_literal: true

Fabricator(:search_result) do
  summary 'SearchResult Summary'
  description 'SearchResult Description'
  user
  project
end

Fabricator(:issue_search_result, from: :search_result) do
  class_name 'Issue'
  issue_type
end

Fabricator(:closed_issue_search_result, from: :issue_search_result) do
  closed true
end

Fabricator(:task_search_result, from: :search_result) do
  class_name 'Task'
  task_type
end

Fabricator(:closed_task_search_result, from: :task_search_result) do
  closed true
end
