# frozen_string_literal: true

# See the wiki for details:
# https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    can :read, Category
    can :read, Issue
    can %i[create update], Issue, user_id: user.id
    can :read, IssueComment
    can %i[create update], IssueComment, user_id: user.id
    can :read, IssueConnection
    can :manage, IssueSubscription, user_id: user.id
    can :create, Progression, user_id: user.id,
                              task: { task_assignees: { assignee_id: user.id } }
    can :read, Progression
    can :finish, Progression, user_id: user.id
    can :read, Project
    can :create, Review, user_id: user.id,
                         task: { task_assignees: { assignee_id: user.id } }
    can :read, Review
    can :destroy, Review, user_id: user.id, approved: nil,
                          task: { closed: false }
    can :read, Task
    can :update, Task, user_id: user.id
    can :read, TaskComment
    can %i[create update], TaskComment, user_id: user.id
    can :read, TaskConnection
    can :manage, TaskSubscription, user_id: user.id
    can :create, Resolution, user_id: user.id, issue: { user_id: user.id }
    can :read, Resolution
    can :read, User
    can :update, User, id: user.id
    return unless user.reviewer? || user.admin?

    can :update, Category
    can :manage, IssueConnection
    can %i[create update], Project
    can %i[approve disapprove], Review, approved: nil
    can :create, Task, user_id: user.id
    can :assign, Task
    can :manage, TaskConnection
    return unless user.admin?

    can %i[create destroy], Category
    can :destroy, Project
    can %i[update destroy open close], Issue
    can %i[update destroy], IssueComment
    can %i[update destroy], TaskComment
    can :manage, IssueType
    can :read, RollerType
    can :manage, TaskType
    can %i[update destroy], Progression
    can %i[update destroy], Resolution
    can %i[update], Review
    can %i[update destroy open close], Task
    can %i[create update destroy], User
    cannot :destroy, User, id: user.id
  end
end
