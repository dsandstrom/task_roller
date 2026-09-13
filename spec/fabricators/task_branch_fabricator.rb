Fabricator(:task_branch, aliases: [:task_branch_from_task]) do
  user

  target do |attrs|
    if attrs[:source_issue]&.project
      Fabricate(:task, project: attrs[:source_issue].project)
    elsif attrs[:source_task]&.project
      Fabricate(:task, project: attrs[:source_task].project)
    else
      Fabricate(:task)
    end
  end

  source_task do |attrs|
    next if attrs[:source_issue]

    if attrs[:target]&.project
      Fabricate(:task, project: attrs[:target].project)
    else
      Fabricate(:task)
    end
  end
end

Fabricator(:task_branch_from_issue, from: :task_branch) do
  source_task { nil }

  source_issue do |attrs|
    if attrs[:target]&.project
      Fabricate(:issue, project: attrs[:target].project)
    else
      Fabricate(:issue)
    end
  end
end
