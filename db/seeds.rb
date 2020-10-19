# frozen_string_literal: true

require 'faker'

class Seeds
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

  def create_issues
    return if Issue.all.any?

    User.reporters.each do |user|
      # open, being worked on, unresolved
      rand(3..11).times { create_issue(user_id: user.id, closed: false) }
      # addressed
      rand(3..11).times do
        create_issue(user_id: user.id, closed: true)
      end
      # resolved
      rand(3..11).times do
        issue = create_issue(user_id: user.id, closed: true)
        issue.resolutions.create!(user_id: user.id, approved: !rand(3).zero?)
      end
    end
  end

  def create_tasks
    return if Task.all.any?

    Issue.all.each do |issue|
      next if rand(5).zero?

      # unassigned
      rand(2).times { create_task(issue_id: issue.id, closed: false) }
      # in progress
      rand(2).times do
        worker = User.workers.ids.sample
        task = create_task(issue_id: issue.id, closed: false,
                           assignee_ids: [worker])
        task.progressions.create!(user_id: worker, finished: false)
      end
      # in review
      rand(2).times do
        task = create_task(issue_id: issue.id, closed: false,
                           assignee_ids: [User.workers.ids.sample])
        task.reviews.create!(user_id: task.user_id, approved: nil)
      end
      # disapproved
      rand(2).times do
        task = create_task(issue_id: issue.id, closed: false,
                           assignee_ids: [User.workers.ids.sample])
        task.reviews.create!(user_id: task.user_id, approved: false)
      end
      # closed tasks
      rand(2).times do
        create_task(issue_id: issue.id, closed: true,
                    assignee_ids: [User.workers.ids.sample])
      end
      # approved
      rand(2).times do
        task = create_task(issue_id: issue.id, closed: true,
                           assignee_ids: [User.workers.ids.sample])
        task.reviews.create!(user_id: task.user_id, approved: true)
      end
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
      attrs.reverse_merge!(
        issue_type_id: IssueType.ids.sample,
        user_id: User.reporters.ids.sample,
        project_id: Project.ids.sample,
        summary: Faker::Company.catch_phrase,
        description: description
      )
      Issue.create!(attrs)
    end

    def create_task(attrs = {})
      description = Faker::Lorem.paragraphs(3, true).join("\r\n")
      attrs.reverse_merge!(
        task_type_id: TaskType.ids.sample,
        user_id: User.reviewers.ids.sample,
        project_id: Project.ids.sample,
        summary: Faker::Company.bs.capitalize,
        description: description
      )
      Task.create!(attrs)
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
seeds.create_issues
seeds.create_tasks
