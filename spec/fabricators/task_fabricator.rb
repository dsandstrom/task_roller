Fabricator(:task) do
  summary { sequence(:tasks) { |n| "Task Summary #{n + 1}" } }
  description 'Task Description'
  task_type
  user { Fabricate(:user_reviewer) }
  project
  status 'unassigned'
end

Fabricator(:unassigned_task, from: :task, aliases: %i[open_task]) do
  closed false
  status 'unassigned'

  after_create do |task|
    task.task_assignees.destroy_all
  end
end

Fabricator(:assigned_task, from: :task) do
  closed false
  status 'assigned'

  after_create do |task|
    next if task.assignees.any?

    Fabricate(:task_assignee, task: task)
  end
end

Fabricator(:in_progress_task, from: :task) do
  closed false
  status 'in_progress'

  after_create do |task|
    next if task.progressions.any?

    progression = Fabricate(:unfinished_progression, task: task)
    Fabricate(:task_assignee, task: task, assignee: progression.user)
  end
end

Fabricator(:finished_task, from: :task) do
  closed false
  status 'assigned'

  after_create do |task|
    if task.progressions.any?
      task.progressions.each(&:finish)
    else
      Fabricate(:finished_progression, task: task)
    end
  end
end

Fabricator(:in_review_task, from: :task) do
  closed false
  status 'in_review'

  after_create do |task|
    next if task.current_review

    Fabricate(:pending_review, task: task)
  end
end

Fabricator(:approved_task, from: :task) do
  closed true
  status 'approved'

  after_create do |task|
    if task.current_review
      task.current_review.update(approved: true)
    else
      Fabricate(:approved_review, task: task)
    end
  end
end

Fabricator(:disapproved_task, from: :task) do
  closed false
  status 'assigned'

  after_create do |task|
    Fabricate(:task_assignee, task: task) if task.assignees.none?

    if task.current_review
      task.current_review.update(approved: false)
    else
      Fabricate(:disapproved_review, task: task)
    end
  end
end

Fabricator(:closed_task, from: :task) do
  closed true
  status 'closed'

  after_create do |task|
    Fabricate(:task_closure, task: task) if task.closures.none?
  end
end

Fabricator(:duplicate_task, from: :task) do
  transient :target

  closed true
  status 'duplicate'

  before_create do |task, transients|
    task.project ||= transients[:target]&.project || Fabricate(:project)
  end

  after_create do |task, transients|
    next if task.source_connection

    transients[:target] ||= Fabricate(:approved_task, project: task.project)
    Fabricate(:task_connection, source: task, target: transients[:target])
  end
end
