Fabricator(:issue_branch, aliases: [:issue_branch_from_issue]) do
  user

  source_issue do |attrs|
    if attrs[:target]&.project
      Fabricate(:issue, project: attrs[:target].project)
    else
      Fabricate(:issue)
    end
  end

  target do |attrs|
    if attrs[:source]&.project
      Fabricate(:issue, project: attrs[:source].project)
    else
      Fabricate(:issue)
    end
  end
end

Fabricator(:issue_branch_from_task, from: :issue_branch) do
  source_issue { nil }

  source_task do |attrs|
    if attrs[:target]&.project
      Fabricate(:task, project: attrs[:target].project)
    else
      Fabricate(:task)
    end
  end
end
