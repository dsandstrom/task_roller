# frozen_string_literal: true

# See the wiki for details:
# https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

# TODO: separate into classes

class Ability # rubocop:disable Metrics/ClassLength
  include CanCan::Ability

  EXTERNAL_CATEGORY_OPTIONS = { visible: true, internal: false }.freeze
  EXTERNAL_PROJECT_OPTIONS = { visible: true, internal: false,
                               category: EXTERNAL_CATEGORY_OPTIONS }.freeze
  VISIBLE_CATEGORY_OPTIONS = { visible: true }.freeze
  VISIBLE_PROJECT_OPTIONS = { visible: true,
                              category: VISIBLE_CATEGORY_OPTIONS }.freeze
  VISIBLE_OPTIONS = { project: { visible: true,
                                 category: VISIBLE_CATEGORY_OPTIONS } }.freeze
  EXTERNAL_OPTIONS = { project: { visible: true, internal: false,
                                  category: EXTERNAL_CATEGORY_OPTIONS } }.freeze

  PROJECT_CLASSES = [Issue, Task].freeze
  CONNECTION_CLASSES = [IssueConnection, TaskConnection].freeze
  ISSUE_CLASSES = [IssueClosure, IssueComment, IssueReopening,
                   Resolution].freeze
  ISSUE_USER_CLASSES = [IssueComment].freeze
  TASK_USER_CLASSES = [TaskComment].freeze
  TASK_CLASSES = [Progression, Review, TaskClosure, TaskComment,
                  TaskReopening].freeze
  REVIEWER_ISSUE_CLASSES = [IssueClosure, IssueReopening].freeze
  REVIEWER_TASK_CLASSES =  [TaskClosure, TaskReopening].freeze
  PROJECT_USER_CLASSES = [ProjectIssuesSubscription,
                          ProjectTasksSubscription].freeze

  def initialize(user)
    return unless user && user.employee_type.present?

    [CategoryAbility, ProjectAbility, UserAbility].each do |klass|
      ability = klass.new(ability: self, user: user)
      ability.activate
    end

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
      basic_assigned_task_abilities(user)
      basic_issue_abilities(user)
      basic_task_abilities(user)
    end

    def basic_read_abilities(_user = nil)
      ISSUE_CLASSES.each { |name| can :read, name, issue: EXTERNAL_OPTIONS }
      PROJECT_CLASSES.each do |name|
        can :read, name, project: EXTERNAL_PROJECT_OPTIONS
      end
      CONNECTION_CLASSES.each do |name|
        can :read, name, source: EXTERNAL_OPTIONS
      end
    end

    def basic_issue_abilities(user)
      can %i[create update], Issue, user_id: user.id,
                                    project: EXTERNAL_PROJECT_OPTIONS
      can :manage, IssueSubscription, user_id: user.id, issue: EXTERNAL_OPTIONS
      can :create, Resolution, user_id: user.id,
                               issue: EXTERNAL_OPTIONS.merge(user_id: user.id)

      ISSUE_USER_CLASSES.each do |name|
        can %i[create update], name, user_id: user.id, issue: EXTERNAL_OPTIONS
      end
    end

    def basic_task_abilities(user)
      can :manage, TaskSubscription, user_id: user.id, task: EXTERNAL_OPTIONS

      TASK_USER_CLASSES.each do |name|
        can %i[create update], name, user_id: user.id, task: EXTERNAL_OPTIONS
      end
    end

    def basic_assigned_task_abilities(user)
      task_params =
        { task_assignees: { assignee_id: user.id } }.merge(EXTERNAL_OPTIONS)

      can :create, Progression, user_id: user.id, task: task_params
      can :finish, Progression, user_id: user.id, task: EXTERNAL_OPTIONS
      can :create, Review, user_id: user.id, task: task_params
      can :destroy, Review, user_id: user.id, approved: nil,
                            task: EXTERNAL_OPTIONS.merge(closed: false)
      TASK_CLASSES.each do |class_name|
        can :read, class_name, task: EXTERNAL_OPTIONS
      end
    end

    def worker_abilities(user)
      worker_read_abilities(user)
      worker_issue_abilities(user)
      worker_task_abilities(user)
      worker_assigned_task_abilities(user)
    end

    def worker_read_abilities(_user)
      PROJECT_CLASSES.each do |name|
        can :read, name, project: VISIBLE_PROJECT_OPTIONS
      end
      CONNECTION_CLASSES.each do |name|
        can :read, name, source: VISIBLE_OPTIONS
      end
    end

    def worker_issue_abilities(user)
      can %i[create update], Issue, user_id: user.id,
                                    project: VISIBLE_PROJECT_OPTIONS
      can :manage, IssueSubscription, user_id: user.id, issue: VISIBLE_OPTIONS
      can :create, Resolution, user_id: user.id,
                               issue: VISIBLE_OPTIONS.merge(user_id: user.id)

      ISSUE_CLASSES.each { |name| can :read, name, issue: VISIBLE_OPTIONS }
      ISSUE_USER_CLASSES.each do |name|
        can %i[create update], name, user_id: user.id, issue: VISIBLE_OPTIONS
      end
    end

    def worker_task_abilities(user)
      can :finish, Progression, user_id: user.id, task: VISIBLE_OPTIONS
      can :manage, TaskSubscription, user_id: user.id, task: VISIBLE_OPTIONS
      can :destroy, Review, user_id: user.id, approved: nil,
                            task: VISIBLE_OPTIONS.merge(closed: false)

      TASK_CLASSES.each { |name| can :read, name, task: VISIBLE_OPTIONS }
      TASK_USER_CLASSES.each do |name|
        can %i[create update], name, user_id: user.id, task: VISIBLE_OPTIONS
      end
    end

    def worker_assigned_task_abilities(user)
      task_params =
        { task_assignees: { assignee_id: user.id } }.merge(VISIBLE_OPTIONS)
      can :create, Review, user_id: user.id, task: task_params
      can :create, Progression, user_id: user.id, task: task_params
    end

    def reviewer_abilities(user)
      reviewer_manage_abilities(user)
      reviewer_issue_abilities(user)
      reviewer_task_abilities(user)
      reviewer_assigned_task_abilities(user)

      [CONNECTION_CLASSES, ISSUE_CLASSES, PROJECT_CLASSES,
       TASK_CLASSES].flatten.each do |model_name|
        can :read, model_name
      end
    end

    def reviewer_manage_abilities(user)
      CONNECTION_CLASSES.each do |model_name|
        can :manage, model_name, user_id: user.id, source: VISIBLE_OPTIONS
        can :destroy, model_name, source: VISIBLE_OPTIONS
      end
    end

    def reviewer_issue_abilities(user)
      can :read, Issue

      REVIEWER_ISSUE_CLASSES.each do |model_name|
        can :create, model_name, user_id: user.id, issue: VISIBLE_OPTIONS
      end
    end

    def reviewer_task_abilities(user)
      can :finish, Progression, user_id: user.id, task: VISIBLE_OPTIONS
      can %i[approve disapprove], Review, approved: nil, task: VISIBLE_OPTIONS
      can %i[create update], Task, user_id: user.id,
                                   project: VISIBLE_PROJECT_OPTIONS
      can :assign, Task, project: VISIBLE_PROJECT_OPTIONS
      can :create, TaskClosure, user_id: user.id,
                                task: VISIBLE_OPTIONS.merge(user_id: user.id)
      can :create, TaskReopening, user_id: user.id, task: VISIBLE_OPTIONS
    end

    def reviewer_assigned_task_abilities(user)
      task_params =
        { task_assignees: { assignee_id: user.id } }.merge(VISIBLE_OPTIONS)

      can :create, Progression, user_id: user.id, task: task_params
      can :create, Review, user_id: user.id, task: task_params
    end

    def admin_abilities(user)
      admin_destroy_abilities
      admin_setup_abilities
      admin_manage_abilities(user)
      admin_task_abilities(user)
    end

    def admin_destroy_abilities
      [CONNECTION_CLASSES, ISSUE_USER_CLASSES,
       PROJECT_CLASSES, REVIEWER_ISSUE_CLASSES, REVIEWER_TASK_CLASSES,
       TASK_USER_CLASSES].flatten.each do |class_name|
        can :destroy, class_name
      end
    end

    def admin_setup_abilities
      [IssueType, TaskType].each do |class_name|
        can :manage, class_name
      end
    end

    def admin_task_abilities(user)
      task_params = { task_assignees: { assignee_id: user.id } }
      can :create, Progression, user_id: user.id, task: task_params
      can :finish, Progression, user_id: user.id

      can :update, Review
      can :destroy, Review, user_id: user.id, approved: nil,
                            task: { closed: false }
      can %i[approve disapprove], Review, approved: nil

      can %i[update destroy assign], Task
    end

    def admin_manage_abilities(user)
      [REVIEWER_ISSUE_CLASSES, REVIEWER_TASK_CLASSES].flatten.each do |name|
        can :create, name, user_id: user.id
      end

      CONNECTION_CLASSES.each do |model_name|
        can :manage, model_name, user_id: user.id
      end

      [Issue, Progression, Resolution, ISSUE_USER_CLASSES,
       TASK_USER_CLASSES].flatten.each do |model_name|
        can %i[update destroy], model_name
      end
    end
end
