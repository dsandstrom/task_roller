# frozen_string_literal: true

# See the wiki for details:
# https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

# TODO: don't allow reading user with nil employee_id

class Ability
  include CanCan::Ability

  REPORTER_CATEGORY_OPTIONS = { visible: true, internal: false }.freeze
  REPORTER_PROJECT_OPTIONS = { visible: true, internal: false,
                               category: REPORTER_CATEGORY_OPTIONS }.freeze
  WORKER_CATEGORY_OPTIONS = { visible: true }.freeze
  WORKER_PROJECT_OPTIONS = { visible: true,
                             category: WORKER_CATEGORY_OPTIONS }.freeze
  MANAGE_CLASSES = [CategoryIssuesSubscription, CategoryTasksSubscription,
                    IssueSubscription, ProjectIssuesSubscription,
                    ProjectTasksSubscription, TaskSubscription].freeze
  READ_CLASSES = [IssueComment, IssueClosure, IssueConnection, IssueReopening,
                  Progression, TaskComment, TaskClosure, TaskConnection,
                  TaskReopening, Resolution, Review, User].freeze
  DESTROY_CLASSES = [Category, IssueClosure, IssueReopening, Project,
                     TaskClosure, TaskReopening].freeze

  def initialize(user)
    return unless user

    basic_abilities(user)
    return if user.reporter?

    worker_abilities(user)
    return if user.worker?

    reviewer_abilities(user)
    return unless user.admin?

    admin_abilities(user)
  end

  private

    def basic_abilities(user)
      basic_read_abilities(user)
      basic_manage_abilities(user)
      basic_assigned_task_abilities(user)
      can :update, User, id: user.id
    end

    def basic_read_abilities(_user = nil)
      can :read, Category, REPORTER_CATEGORY_OPTIONS
      can :read, Project, REPORTER_PROJECT_OPTIONS
      can :read, Issue, project: REPORTER_PROJECT_OPTIONS
      can :read, Task, project: REPORTER_PROJECT_OPTIONS
      READ_CLASSES.each do |class_name|
        can :read, class_name
      end
    end

    def basic_manage_abilities(user)
      can %i[create update], Issue, user_id: user.id,
                                    project: REPORTER_PROJECT_OPTIONS
      can %i[create update], IssueComment, user_id: user.id
      can %i[create update], TaskComment, user_id: user.id
      can :create, Resolution, user_id: user.id, issue: { user_id: user.id }
      MANAGE_CLASSES.each do |class_name|
        can :manage, class_name, user_id: user.id
      end
    end

    def basic_assigned_task_abilities(user)
      task_params = { task_assignees: { assignee_id: user.id } }

      can :create, Progression, user_id: user.id, task: task_params
      can :finish, Progression, user_id: user.id
      can :create, Review, user_id: user.id, task: task_params
      can :destroy, Review, user_id: user.id, approved: nil,
                            task: { closed: false }
    end

    def worker_abilities(user)
      can :read, Category, WORKER_CATEGORY_OPTIONS
      can :read, Project, WORKER_PROJECT_OPTIONS
      can :read, Issue, project: WORKER_PROJECT_OPTIONS
      can :read, Task, project: WORKER_PROJECT_OPTIONS
      can %i[create update], Issue, user_id: user.id,
                                    project: WORKER_PROJECT_OPTIONS
    end

    def reviewer_abilities(user)
      can %i[create read update], Category
      can %i[create read update], Project
      reviewer_issue_abilities(user)
      reviewer_task_abilities(user)
    end

    def reviewer_issue_abilities(user)
      can :create, Issue, user_id: user.id, project: WORKER_PROJECT_OPTIONS
      can :read, Issue
      can :update, Issue, user_id: user.id
      can :create, IssueClosure, user_id: user.id
      can :manage, IssueConnection, user_id: user.id
      can :destroy, IssueConnection
      can :create, IssueReopening, user_id: user.id
      can %i[approve disapprove], Review, approved: nil
    end

    def reviewer_task_abilities(user)
      can :create, Task, user_id: user.id, project: WORKER_PROJECT_OPTIONS
      can %i[read assign], Task
      can :update, Task, user_id: user.id
      can :manage, TaskConnection, user_id: user.id
      can :destroy, TaskConnection
      can :create, TaskClosure, user_id: user.id, task: { user_id: user.id }
      can :create, TaskReopening, user_id: user.id
    end

    def admin_abilities(user)
      admin_issue_abilities(user)
      admin_task_abilities(user)
      admin_manage_abilities
      admin_destroy_abilities
      can %i[create update destroy], User
      cannot :destroy, User, id: user.id
      can :create, TaskClosure, user_id: user.id
    end

    def admin_destroy_abilities
      DESTROY_CLASSES.each do |class_name|
        can :destroy, class_name
      end
    end

    def admin_manage_abilities
      [IssueType, TaskType].each do |class_name|
        can :manage, class_name
      end
    end

    def admin_issue_abilities(_user)
      can %i[update destroy open close], Issue
      can %i[update destroy], IssueComment
      can %i[update destroy], Resolution
    end

    def admin_task_abilities(_user)
      can %i[update destroy open close], Task
      can %i[update destroy], TaskComment
      can %i[update destroy], Progression
      can %i[update], Review
    end
end
