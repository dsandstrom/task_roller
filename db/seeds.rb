# frozen_string_literal: true

require 'faker'

class Seeds
  def create_admins
    return if Admin.any?

    3.times { create_user('Admin') }
  end

  def create_reporters
    return if Reporter.any?

    11.times { create_user('Reporter') }
  end

  def create_reviewers
    return if Reviewer.any?

    6.times { create_user('Reviewer') }
  end

  def create_workers
    return if Worker.any?

    5.times { create_user('Worker') }
  end

  def create_categories
    return if Category.any?

    rand(11).times do
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

    Project.all.each do |project|
      rand(11..23).times { create_issue(project) }
    end
  end

  private

    def create_user(employee_type)
      User.create!(name: Faker::Name.unique.name,
                   email: Faker::Internet.unique.email,
                   employee_type: employee_type)
    end

    def create_issue(project)
      description = Faker::Lorem.paragraphs(3, true).join("\r\n")
      project.issues.create!(issue_type_id: IssueType.ids.sample,
                             user_id: Reporter.ids.sample,
                             summary: Faker::Company.catch_phrase,
                             description: description)
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
