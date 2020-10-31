# frozen_string_literal: true

# See the wiki for details:
# https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    global_abilities(user)
    return unless user.reviewer? || user.admin?

    reviewer_abilities(user)
    return unless user.admin?

    admin_abilities(user)
  end

  private

    def global_abilities(user)
      issue_abilities(user)
      task_abilities(user)
      task_review_abilities(user)
      can :read, Category
      can :read, Issue
      can :read, Project
      can :read, User
      can :update, User, id: user.id
    end

    def issue_abilities(user)
      can %i[create update], Issue, user_id: user.id
      can :read, IssueComment
      can %i[create update], IssueComment, user_id: user.id
      can :read, IssueConnection
      can :manage, IssueSubscription, user_id: user.id
      can :create, Resolution, user_id: user.id, issue: { user_id: user.id }
      can :read, Resolution
    end

    def task_abilities(user)
      can :read, Task
      can :update, Task, user_id: user.id
      can :read, TaskComment
      can %i[create update], TaskComment, user_id: user.id
      can :read, TaskConnection
      can :manage, TaskSubscription, user_id: user.id
    end

    def task_review_abilities(user)
      task_params = { task_assignees: { assignee_id: user.id } }
      can :create, Progression, user_id: user.id, task: task_params
      can :read, Progression
      can :finish, Progression, user_id: user.id
      can :create, Review, user_id: user.id, task: task_params
      can :read, Review
      can :destroy, Review, user_id: user.id, approved: nil,
                            task: { closed: false }
    end

    def reviewer_abilities(user)
      can :update, Category
      can :manage, IssueConnection
      can %i[create update], Project
      can %i[approve disapprove], Review, approved: nil
      can :create, Task, user_id: user.id
      can :assign, Task
      can :manage, TaskConnection
    end

    def admin_abilities(user)
      admin_issue_abilities(user)
      admin_task_abilities(user)
      can %i[create destroy], Category
      can :destroy, Project
      can :manage, IssueType
      can :read, RollerType
      can :manage, TaskType
      can %i[create update destroy], User
      cannot :destroy, User, id: user.id
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
