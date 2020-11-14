# frozen_string_literal: true

require 'faker'

class Seeds
  def create_admins
    2.times { create_user('Admin') }
  end

  def create_reporters
    12.times { create_user('Reporter') }
  end

  def create_reviewers
    4.times { create_user('Reviewer') }
  end

  def create_workers
    10.times { create_user('Worker') }
  end

  def create_categories
    6.times do
      name = Faker::Commerce.unique.department

      category = Category.create!(name: name, visible: random_visible,
                                  internal: random_internal)
      create_category_subscriptions(category)
      create_projects(category)
    end
  end

  def create_issue_types
    IssueType.create!(name: 'Bug', color: 'red', icon: 'bug')
    IssueType.create!(name: 'Suggestion', color: 'green', icon: 'options')
    IssueType.create!(name: 'Question', color: 'blue', icon: 'help')
  end

  def create_task_types
    TaskType.create!(name: 'Bug', color: 'red', icon: 'bug')
    TaskType.create!(name: 'Improvement', color: 'yellow', icon: 'options')
    TaskType.create!(name: 'Feature Request', color: 'green', icon: 'bulb')
  end

  # TODO: add comments
  def create_issues_and_tasks
    User.reporters.each do |user|
      create_open_user_issues(user)
      create_closed_user_issues(user)
    end
  end

  def create_separate_tasks
    User.reviewers.each do |user|
      rand(3..11).times { create_reopened_task(user) }
      rand(1..5).times { create_duplicate_task(user) }
    end
  end

  def create_comments
    create_issue_comments
    create_task_comments
  end

  def create_issue_comments
    Issue.all.each do |issue|
      if issue.comments.none?
        issue.comments.create(user_id: random_reviewer_id,
                              body: comment_question)
        issue.comments.create(user_id: issue.user_id, body: comment_body)
      end
      next unless issue.open? && issue.tasks.all_assigned.any?

      assignee_id = issue.tasks.all_assigned.sample.assignee_ids.sample
      issue.comments.create(user_id: assignee_id, body: comment_question)
      if rand(2).zero?
        issue.comments.create(user_id: issue.user_id, body: comment_body)
      end
      if rand(2).zero?
        issue.comments.create(user_id: random_reviewer_id, body: comment_body)
      end
    end
  end

  def create_task_comments
    Task.all.each do |task|
      if task.comments.none?
        if task.assignees.any?
          assignee_id = task.assignee_ids.sample
          task.comments.create(user_id: assignee_id, body: comment_question)
        else
          task.comments.create(user_id: random_reviewer_id,
                               body: comment_question)
        end
        if task.issue && rand(2).zero?
          task.comments.create(user_id: task.issue.user_id, body: comment_body)
        end
        task.comments.create(user_id: task.user_id, body: comment_body)
        if task.current_review
          user_id = task.current_review.user_id
          task.comments.create(user_id: user_id, body: comment_body)
        end
      elsif task.assignees.any?
        assignee_id = task.assignee_ids.sample
        task.comments.create(user_id: assignee_id, body: comment_question)
        if task.issue && rand(2).zero?
          task.comments.create(user_id: task.issue.user_id,
                               body: comment_body)
        end
        task.comments.create(user_id: task.user_id, body: comment_body)
      elsif task.open?
        task.comments.create(user_id: random_reviewer_id,
                             body: comment_question)
        task.comments.create(user_id: task.user_id, body: comment_body)
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
      attrs.reverse_merge!(issue_type_id: IssueType.ids.sample,
                           user_id: User.reporters.ids.sample,
                           project_id: Project.ids.sample,
                           summary: Faker::Company.catch_phrase,
                           description: issue_description)
      issue = Issue.create!(attrs)
      issue.subscribe_users
      issue
    end

    def create_task(attrs = {})
      attrs.reverse_merge!(task_type_id: TaskType.ids.sample,
                           user_id: User.reviewers.ids.sample,
                           project_id: Project.ids.sample,
                           summary: Faker::Company.bs.capitalize,
                           description: task_description)
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

    def create_closed_issue(user)
      issue = create_issue(user_id: user.id, closed: true)
      issue.closures.create!(user_id: random_reviewer_id)
      issue
    end

    def create_reopened_issue(user)
      issue = create_issue(user_id: user.id, closed: false)
      reviewer_id = random_reviewer_id
      issue.closures.create!(user_id: reviewer_id)
      issue.reopenings.create!(user_id: reviewer_id)
      issue
    end

    def create_duplicate_issue(user)
      duplicate_issue = Issue.all.sample
      return unless duplicate_issue

      issue = create_issue(user_id: user.id, closed: true,
                           project_id: duplicate_issue.project_id)
      IssueConnection.create!(source_id: issue.id,
                              target_id: duplicate_issue.id,
                              user_id: random_reviewer_id)
      issue
    end

    def create_open_task(issue, worker = nil)
      worker ||= User.workers.sample
      create_task(issue_id: issue.id, closed: false, assignee_ids: [worker.id])
    end

    def create_closed_task(issue, worker = nil)
      worker ||= User.workers.sample
      create_task(issue_id: issue.id, closed: true, assignee_ids: [worker.id])
    end

    def create_reopened_task(reviewer)
      worker ||= User.workers.sample
      task = create_task(closed: false, assignee_ids: [worker.id])
      task.closures.create!(user_id: reviewer.id)
      task.reopenings.create!(user_id: reviewer.id)
      task
    end

    def create_duplicate_task(reviewer)
      duplicate = Task.all.sample
      task = create_task(closed: true, project_id: duplicate.project_id)
      TaskConnection.create!(source_id: task.id, target_id: duplicate.id,
                             user_id: reviewer.id)
      task
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
      task = create_open_task(issue, worker)
      create_finished_progression(task, worker)
      task.reviews.create!(user_id: task.user_id, approved: false)
      task
    end

    # TODO: don't allow user to have multiple subscriptions of same type
    def create_category_subscriptions(category)
      rand(5..15).times do
        category.category_issues_subscriptions.create(user_id: random_user_id)
      end
      rand(5..15).times do
        category.category_tasks_subscriptions.create(user_id: random_user_id)
      end
    end

    def create_projects(category)
      return if category.projects.any?

      rand(11).times do
        name = Faker::App.unique.name

        project = category.projects.create!(name: name, visible: random_visible,
                                            internal: random_internal)
        create_project_subscriptions(project)
      end
    end

    def create_project_subscriptions(project)
      rand(5..15).times do
        project.project_issues_subscriptions.create(user_id: random_user_id)
      end
      rand(5..15).times do
        project.project_tasks_subscriptions.create(user_id: random_user_id)
      end
    end

    def random_visible
      rand(2).zero?
    end

    def random_internal
      rand(4).zero?
    end

    def user_ids
      @user_ids ||= User.ids
    end

    def random_user_id
      user_ids.sample
    end

    def reviewer_ids
      @reviewer_ids ||= User.reviewers.ids
    end

    def random_reviewer_id
      reviewer_ids.sample
    end

    def create_open_user_issues(user)
      rand(3..11).times { create_open_issue(user) }
      rand(3..11).times { create_being_worked_issue(user) }
      rand(1..5).times { create_reopened_issue(user) }
    end

    def create_closed_user_issues(user)
      rand(3..11).times { create_addressed_issue(user) }
      rand(3..11).times { create_resolved_issue(user) }
      rand(3..11).times { create_closed_issue(user) }
      rand(1..5).times { create_duplicate_issue(user) }
    end

    def comment_body
      p_options = { sentence_count: 2, random_sentences_to_add: 4 }

      body = "#{Faker::Lorem.paragraph(p_options)}\n\n"
      body += "#{Faker::Markdown.random('table')}\n\n" if rand(2).zero?
      body += Faker::Lorem.paragraph(p_options)
      body
    end

    def comment_question
      p_options = { sentence_count: 2, random_sentences_to_add: 4 }
      q_options = { word_count: 2, random_words_to_add: 4 }

      body = "#{Faker::Lorem.paragraph(p_options)} "
      body += "#{Faker::Lorem.question(q_options)}\n\n"
      body += "#{Faker::Markdown.random('table')}\n\n" if rand(2).zero?
      body += "#{Faker::Lorem.paragraph(p_options)} "
      body += Faker::Lorem.question(q_options)
      body
    end

    def issue_description
      p_options = { sentence_count: 3, random_sentences_to_add: 5 }
      q_options = { word_count: 3, random_words_to_add: 6 }

      body = "#{Faker::Lorem.paragraph(p_options)} "
      body += "#{Faker::Lorem.question(q_options)}\n\n"
      body += "#{Faker::Markdown.random('table')}\n\n" if rand(2).zero?
      body += "#{Faker::Lorem.paragraph(p_options)} "
      body += Faker::Lorem.question(q_options)
      body
    end

    def task_description
      p_options = { sentence_count: 2, random_sentences_to_add: 4 }

      body = "#{Faker::Lorem.paragraph(p_options)}\n\n"
      body += "#{Faker::Markdown.random('table')}\n\n" if rand(2).zero?
      body += Faker::Lorem.paragraph(p_options)
      body
    end
end

seeds = Seeds.new
seeds.create_issue_types if IssueType.none?
seeds.create_task_types if TaskType.none?
seeds.create_admins if User.admins.none?
seeds.create_reporters if User.reporters.none?
seeds.create_reviewers if User.reviewers.none?
seeds.create_workers if User.workers.none?
seeds.create_categories if Category.none? || Project.none?
seeds.create_issues_and_tasks
seeds.create_separate_tasks
seeds.create_comments
