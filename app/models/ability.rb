# frozen_string_literal: true

# See the wiki for details:
# https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

class Ability
  include CanCan::Ability

  EXTERNAL_CATEGORY_OPTIONS = { visible: true, internal: false }.freeze
  EXTERNAL_PROJECT_OPTIONS = { visible: true, internal: false,
                               category: EXTERNAL_CATEGORY_OPTIONS }.freeze
  VISIBLE_CATEGORY_OPTIONS = { visible: true }.freeze
  VISIBLE_PROJECT_OPTIONS = { visible: true,
                              category: VISIBLE_CATEGORY_OPTIONS }.freeze
  MANAGE_CLASSES = [CategoryIssuesSubscription, CategoryTasksSubscription,
                    IssueSubscription, ProjectIssuesSubscription,
                    ProjectTasksSubscription, TaskSubscription].freeze
  READ_CLASSES = [IssueClosure, IssueConnection, IssueReopening, Progression,
                  TaskClosure, TaskConnection, TaskReopening, Resolution,
                  Review].freeze
  DESTROY_CLASSES = [Category, IssueClosure, IssueReopening, Project,
                     TaskClosure, TaskReopening].freeze

  def initialize(user)
    return unless user && user.employee_type.present?

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
      can :read, User
      cannot :read, User, employee_type: nil
      can :update, User, id: user.id
      cannot :update, User, employee_type: nil
    end

    def basic_read_abilities(_user = nil)
      can :read, Category, EXTERNAL_CATEGORY_OPTIONS
      can :read, Project, EXTERNAL_PROJECT_OPTIONS
      can :read, Issue, project: EXTERNAL_PROJECT_OPTIONS
      can :read, IssueComment, issue: { project: EXTERNAL_PROJECT_OPTIONS }
      can :read, Task, project: EXTERNAL_PROJECT_OPTIONS
      can :read, TaskComment, task: { project: EXTERNAL_PROJECT_OPTIONS }
      READ_CLASSES.each do |class_name|
        can :read, class_name
      end
    end

    def basic_manage_abilities(user)
      can %i[create update], Issue, user_id: user.id,
                                    project: EXTERNAL_PROJECT_OPTIONS
      can %i[create update], IssueComment,
          user_id: user.id, issue: { project: EXTERNAL_PROJECT_OPTIONS }
      can %i[create update], TaskComment,
          user_id: user.id, task: { project: EXTERNAL_PROJECT_OPTIONS }
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
      can :read, Category, VISIBLE_CATEGORY_OPTIONS
      can :read, Project, VISIBLE_PROJECT_OPTIONS
      worker_issue_abilities(user)
      worker_task_abilities(user)
    end

    def worker_issue_abilities(user)
      can :read, Issue, project: VISIBLE_PROJECT_OPTIONS
      can %i[create update], Issue, user_id: user.id,
                                    project: VISIBLE_PROJECT_OPTIONS
      can %i[create update], IssueComment,
          user_id: user.id, issue: { project: VISIBLE_PROJECT_OPTIONS }
      can :read, IssueComment, issue: { project: VISIBLE_PROJECT_OPTIONS }
    end

    def worker_task_abilities(user)
      can :read, Task, project: VISIBLE_PROJECT_OPTIONS
      can %i[create update], TaskComment,
          user_id: user.id, task: { project: VISIBLE_PROJECT_OPTIONS }
      can :read, TaskComment, task: { project: VISIBLE_PROJECT_OPTIONS }
    end

    def reviewer_abilities(user)
      can %i[create read update], Category
      can %i[create read update], Project
      reviewer_issue_abilities(user)
      reviewer_task_abilities(user)
    end

    def reviewer_issue_abilities(user)
      can :read, Issue
      can :update, Issue, user_id: user.id
      can :create, IssueClosure, user_id: user.id
      can :read, IssueComment
      can :manage, IssueConnection, user_id: user.id
      can :destroy, IssueConnection
      can :create, IssueReopening, user_id: user.id
      can %i[approve disapprove], Review, approved: nil
    end

    def reviewer_task_abilities(user)
      can :create, Task, user_id: user.id, project: VISIBLE_PROJECT_OPTIONS
      can %i[read assign], Task
      can :update, Task, user_id: user.id
      can :read, TaskComment
      can :manage, TaskConnection, user_id: user.id
      can :destroy, TaskConnection
      can :create, TaskClosure, user_id: user.id, task: { user_id: user.id }
      can :create, TaskReopening, user_id: user.id
    end

    def admin_abilities(user)
      admin_destroy_abilities
      admin_setup_abilities
      admin_issue_abilities(user)
      admin_task_abilities(user)
      admin_user_abilities(user)
    end

    def admin_destroy_abilities
      DESTROY_CLASSES.each do |class_name|
        can :destroy, class_name
      end
    end

    def admin_setup_abilities
      [IssueType, TaskType].each do |class_name|
        can :manage, class_name
      end
    end

    def admin_issue_abilities(_user)
      can %i[update destroy open close], Issue
      can %i[update destroy], IssueComment
      can %i[update destroy], Resolution
    end

    def admin_task_abilities(user)
      can %i[update destroy open close], Task
      can :create, TaskClosure, user_id: user.id
      can %i[update destroy], TaskComment
      can %i[update destroy], Progression
      can %i[update], Review
    end

    def admin_user_abilities(user)
      can :manage, User
      cannot :create, User, employee_type: nil
      cannot :destroy, User, id: user.id
    end
end
