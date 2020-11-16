# frozen_string_literal: true

# See the wiki for details:
# https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

# TODO: don't allow reading user with nil employee_id

class Ability
  include CanCan::Ability

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
      can :read, Category, visible: true, internal: false
      can :read, Project, visible: true, internal: false,
                          category: { visible: true, internal: false }
      can :read, Issue,
          project: { visible: true, internal: false,
                     category: { visible: true, internal: false } }
      [IssueComment, IssueClosure, IssueConnection,
       IssueReopening, Progression, Task, TaskComment, TaskClosure,
       TaskConnection, TaskReopening, Resolution, Review,
       User].each do |class_name|
        can :read, class_name
      end
    end

    def basic_manage_abilities(user)
      can %i[create update], Issue,
          user_id: user.id,
          project: { visible: true, internal: false,
                     category: { visible: true, internal: false } }
      can :update, Task, user_id: user.id
      can %i[create update], IssueComment, user_id: user.id
      can %i[create update], TaskComment, user_id: user.id
      can :create, Resolution, user_id: user.id, issue: { user_id: user.id }
      [CategoryIssuesSubscription, CategoryTasksSubscription, IssueSubscription,
       ProjectIssuesSubscription, ProjectTasksSubscription,
       TaskSubscription].each do |class_name|
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
      can :read, Category, visible: true
      can :read, Project, visible: true, category: { visible: true }
      can :read, Issue, project: { visible: true, category: { visible: true } }
      can %i[create update], Issue,
          user_id: user.id,
          project: { visible: true, category: { visible: true } }
    end

    def reviewer_abilities(user)
      can %i[create read update], Category
      can %i[create read update], Project
      can :read, Issue
      reviewer_issue_abilities(user)
      reviewer_task_abilities(user)
    end

    def reviewer_issue_abilities(user)
      can :create, IssueClosure, user_id: user.id
      can :create, IssueReopening, user_id: user.id
      can :create, TaskClosure, user_id: user.id, task: { user_id: user.id }
      can :create, TaskReopening, user_id: user.id
      can :manage, IssueConnection, user_id: user.id
      can :destroy, IssueConnection
      can %i[approve disapprove], Review, approved: nil
    end

    def reviewer_task_abilities(user)
      can :create, Task, user_id: user.id
      can %i[create update], Issue, user_id: user.id
      can :assign, Task
      can :manage, TaskConnection, user_id: user.id
      can :destroy, TaskConnection
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
      [Category, IssueClosure, IssueReopening, Project, TaskClosure,
       TaskReopening].each do |class_name|
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
