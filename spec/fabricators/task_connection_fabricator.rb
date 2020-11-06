# frozen_string_literal: true

Fabricator(:task_connection) do
  source do |attrs|
    if attrs[:target]&.project
      Fabricate(:task, project: attrs[:target].project)
    else
      Fabricate(:task)
    end
  end
  target do |attrs|
    if attrs[:source].project
      Fabricate(:task, project: attrs[:source].project)
    else
      Fabricate(:task)
    end
  end
end
