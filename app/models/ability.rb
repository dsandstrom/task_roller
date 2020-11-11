# frozen_string_literal: true

# See the wiki for details:
# https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    basic_abilities(user)
    return unless user.reviewer? || user.admin?

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
      [Category, Issue, IssueComment, IssueClosure, IssueConnection,
       IssueReopening, Progression, Project, Task, TaskComment, TaskClosure,
       TaskConnection, TaskReopening, Resolution, Review,
       User].each do |class_name|
        can :read, class_name
      end
    end

    def basic_manage_abilities(user)
      can %i[create update], Issue, user_id: user.id
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

    def reviewer_abilities(user)
      can %i[create update], Category
      can %i[create update], Project
      reviewer_issue_abilities(user)
      reviewer_task_abilities(user)
    end

    def reviewer_issue_abilities(user)
      can %i[open close], Issue
      can :create, IssueClosure, user_id: user.id
      can :create, IssueReopening, user_id: user.id
      can :create, TaskClosure, user_id: user.id, task: { user_id: user.id }
      can :create, TaskReopening, user_id: user.id
      can :manage, IssueConnection, user_id: user.id
      can :destroy, IssueConnection
      can %i[approve disapprove], Review, approved: nil
    end

    def reviewer_task_abilities(user)
      can %i[create open close], Task, user_id: user.id
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
