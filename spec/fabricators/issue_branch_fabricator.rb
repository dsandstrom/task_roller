Fabricator(:issue_branch, aliases: [:issue_branch_from_issue]) do
  user

  target do |attrs|
    if attrs[:source_issue]&.project
      Fabricate(:issue, project: attrs[:source_issue].project)
    elsif attrs[:source_task]&.project
      Fabricate(:issue, project: attrs[:source_task].project)
    else
      Fabricate(:issue)
    end
  end

  source_issue do |attrs|
    next if attrs[:source_task]

    if attrs[:target]&.project
      Fabricate(:issue, project: attrs[:target].project)
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
