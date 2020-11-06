# frozen_string_literal: true

Fabricator(:issue_connection) do
  source do |attrs|
    if attrs[:target]&.project
      Fabricate(:issue, project: attrs[:target].project)
    else
      Fabricate(:issue)
    end
  end
  target do |attrs|
    if attrs[:source].project
      Fabricate(:issue, project: attrs[:source].project)
    else
      Fabricate(:issue)
    end
  end
end
