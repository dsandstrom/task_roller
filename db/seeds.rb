# frozen_string_literal: true

# TODO: create category/project subscriptions

require 'faker'

class Seeds # rubocop:disable Metrics/ClassLength
  def create_admins
    return if User.admins.any?

    2.times { create_user('Admin') }
  end

  def create_reporters
    return if User.reporters.any?

    12.times { create_user('Reporter') }
  end

  def create_reviewers
    return if User.reviewers.any?

    4.times { create_user('Reviewer') }
  end

  def create_workers
    return if User.workers.any?

    10.times { create_user('Worker') }
  end

  def create_categories
    return if Category.any?

    6.times do
      name = Faker::Commerce.unique.department

      Category.create!(name: name, visible: random_visible,
                       internal: random_internal)
    end
  end

  def create_projects
    Category.all.each do |category|
      next if category.projects.any?

      rand(11).times do
        name = Faker::App.unique.name

        category.projects.create!(name: name, visible: random_visible,
                                  internal: random_internal)
      end
    end
  end

  def create_issue_types
    return if IssueType.all.any?

    IssueType.create!(name: 'Bug', color: 'red', icon: 'bug')
    IssueType.create!(name: 'Suggestion', color: 'green', icon: 'options')
    IssueType.create!(name: 'Question', color: 'blue', icon: 'help')
  end

  def create_task_types
    return if TaskType.all.any?

    TaskType.create!(name: 'Bug', color: 'red', icon: 'bug')
    TaskType.create!(name: 'Improvement', color: 'yellow', icon: 'options')
    TaskType.create!(name: 'Feature Request', color: 'green', icon: 'bulb')
  end

  def create_issues_and_tasks
    return if Issue.all.any?

    User.reporters.each do |user|
      rand(3..11).times { create_open_issue(user) }
      rand(3..11).times { create_being_worked_issue(user) }
      rand(3..11).times { create_addressed_issue(user) }
      rand(3..11).times { create_resolved_issue(user) }
    end
  end

  private

    def create_user(employee_type)
      User.create!(name: Faker::Name.unique.name,
                   email: Faker::Internet.unique.email,
                   employee_type: employee_type)
    end

    def create_issue(attrs = {})
      description = Faker::Lorem.paragraphs(3, true).join("\r\n")
      attrs.reverse_merge!(issue_type_id: IssueType.ids.sample,
                           user_id: User.reporters.ids.sample,
                           project_id: Project.ids.sample,
                           summary: Faker::Company.catch_phrase,
                           description: description)
      issue = Issue.create!(attrs)
      issue.subscribe_users
      issue
    end

    def create_task(attrs = {})
      description = Faker::Lorem.paragraphs(3, true).join("\r\n")
      attrs.reverse_merge!(task_type_id: TaskType.ids.sample,
                           user_id: User.reviewers.ids.sample,
                           project_id: Project.ids.sample,
                           summary: Faker::Company.bs.capitalize,
                           description: description)
      task = Task.create!(attrs)
      task.subscribe_users
      task
    end

    def create_open_issue(user)
      create_issue(user_id: user.id, closed: false)
    end

    def create_being_worked_issue(user) # rubocop:disable Metrics/AbcSize
      issue = create_open_issue(user)
      if rand(2).zero?
        rand(2).times { create_open_task(issue) }
      else
        rand(2).times { create_unassigned_task(issue) }
        rand(2).times { create_in_progress_task(issue) }
        rand(2).times { create_disapproved_task(issue) }
        rand(2).times { create_in_review_task(issue) }
      end
    end

    def create_addressed_issue(user)
      issue = create_issue(user_id: user.id, closed: true)
      rand(1..3).times { create_approved_task(issue) }
      issue
    end

    def create_resolved_issue(user)
      issue = create_issue(user_id: user.id, closed: true)
      issue.resolutions.create!(user_id: user.id, approved: !rand(3).zero?)
      issue
    end

    def create_open_task(issue, worker = nil)
      worker ||= User.workers.sample
      create_task(issue_id: issue.id, closed: false,
                  assignee_ids: [worker.id])
    end

    def create_closed_task(issue, worker = nil)
      worker ||= User.workers.sample
      create_task(issue_id: issue.id, closed: true,
                  assignee_ids: [worker.id])
    end

    def create_unassigned_task(issue)
      create_task(issue_id: issue.id, closed: false)
    end

    def create_unfinished_progression(task, worker)
      task.progressions.create!(user_id: worker.id, finished: false)
    end

    def create_finished_progression(task, worker)
      task.progressions.create!(user_id: worker.id, finished: true,
                                finished_at: Time.now)
    end

    def create_in_progress_task(issue)
      worker = User.workers.sample
      task = create_open_task(issue, worker)
      create_unfinished_progression(task, worker)
      task
    end

    def create_in_review_task(issue)
      worker = User.workers.sample
      task = create_open_task(issue, worker)
      create_finished_progression(task, worker)
      task.reviews.create!(user_id: worker.id, approved: nil)
      task
    end

    def create_approved_task(issue)
      worker = User.workers.sample
      task = create_closed_task(issue, worker)
      create_finished_progression(task, worker)
      task.reviews.create!(user_id: task.user_id, approved: true)
      task
    end

    def create_disapproved_task(issue)
      worker = User.workers.sample
      task = create_closed_task(issue, worker)
      create_finished_progression(task, worker)
      task.reviews.create!(user_id: task.user_id, approved: false)
      task
    end

    def random_visible
      rand(2).zero?
    end

    def random_internal
      rand(4).zero?
    end
end

seeds = Seeds.new
seeds.create_admins
seeds.create_reporters
seeds.create_reviewers
seeds.create_workers
seeds.create_categories
seeds.create_projects
seeds.create_issue_types
seeds.create_task_types
seeds.create_issues_and_tasks
