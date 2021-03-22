# frozen_string_literal: true

Fabricator(:task) do
  summary { sequence(:tasks) { |n| "Task Summary #{n + 1}" } }
  description 'Task Description'
  task_type
  user { Fabricate(:user_reviewer) }
  project
  status 'open'
end

Fabricator(:open_task, from: :task) do
  closed false
end

Fabricator(:closed_task, from: :task) do
  closed true
  status 'closed'
end

Fabricator(:in_progress_task, from: :open_task) do
  status 'in_progress'

  after_create do |task|
    return if task.progressions.any?

    Fabricate(:unfinished_progression, task: task)
  end
end

Fabricator(:finished_task, from: :open_task) do
  status 'assigned'

  after_create do |task|
    return if task.progressions.any?

    Fabricate(:finished_progression, task: task)
  end
end

Fabricator(:in_review_task, from: :open_task) do
  status 'in_review'

  after_create do |task|
    return if task.current_review

    Fabricate(:pending_review, task: task)
  end
end

Fabricator(:approved_task, from: :closed_task) do
  status 'approved'

  after_create do |task|
    return if task.current_review

    Fabricate(:approved_review, task: task)
  end
end

Fabricator(:disapproved_task, from: :closed_task) do
  status 'open'

  after_create do |task|
    return if task.current_review

    Fabricate(:disapproved_review, task: task)
  end
end

Fabricator(:duplicate_task, from: :closed_task) do
  status 'duplicate'
  source_connection { Fabricate(:task_connection) }
end
