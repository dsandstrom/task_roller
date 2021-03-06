# frozen_string_literal: true

class TaskAbility < BaseAbility
  def activate
    if user.admin?
      activate_admin
    elsif user.reviewer?
      activate_reviewer
    elsif user.worker?
      activate_worker
    else
      activate_reporter
    end
  end

  private

    def activate_admin
      activate_reviewer
      activate_invisible_abilities

      ability.can :manage, TaskType

      [Task, TaskComment, Progression, Review].each do |model_name|
        ability.can :update, model_name
      end

      [Progression, Task, TaskComment, TaskConnection, TaskClosure,
       TaskReopening].each do |model_name|
        ability.can :destroy, model_name
      end
    end

    def activate_reviewer
      activate_visible_abilities
      activate_visible_assigned_abilities
      activate_invisible_read_abilities
      activate_visible_task_abilities
      activate_visible_review_abilities
    end

    def activate_worker
      activate_visible_abilities
      activate_visible_assigned_abilities
      activate_visible_read_abilities
    end

    def activate_reporter
      activate_external_abilities
      activate_external_read_abilities
    end

    def activate_visible_abilities
      options = { user_id: user_id, task: Ability::VISIBLE_OPTIONS }

      ability.can %i[create update], TaskComment, options
      ability.can :manage, TaskNotification, options
      ability.can :manage, TaskSubscription, options
      ability.can %i[read update destroy], TaskAssignee,
                  assignee_id: user_id, task: Ability::VISIBLE_OPTIONS
      ability.can :create, TaskAssignee,
                  task: Ability::VISIBLE_OPTIONS.merge(closed: false)
      ability.cannot :create, TaskAssignee,
                     task: { task_assignees: { assignee_id: user_id } }
    end

    def activate_visible_assigned_abilities
      task_params =
        Ability::VISIBLE_OPTIONS
        .merge(closed: false, task_assignees: { assignee_id: user_id })

      ability.can :create, Progression, user_id: user_id, task: task_params
      ability.can :finish, Progression,
                  user_id: user_id, task: Ability::VISIBLE_OPTIONS
      ability.can :create, Review, user_id: user_id, task: task_params
      ability.can :destroy, Review,
                  user_id: user_id, approved: nil,
                  task: Ability::VISIBLE_OPTIONS.merge(closed: false)
    end

    def activate_invisible_abilities
      activate_invisible_assigned_abilities
      activate_invisible_task_review_abilities
    end

    def activate_invisible_assigned_abilities
      task_params = { task_assignees: { assignee_id: user_id } }

      ability.can :create, Progression, user_id: user_id, task: task_params
      ability.can :finish, Progression, user_id: user_id
      ability.can :assign, Task
    end

    def activate_external_abilities
      options = { user_id: user_id, task: Ability::EXTERNAL_OPTIONS }

      ability.can %i[create update], TaskComment, options
      ability.can :manage, TaskNotification, options
      ability.can :manage, TaskSubscription, options
    end

    def activate_external_read_abilities
      ability.can :read, Task, project: Ability::EXTERNAL_PROJECT_OPTIONS
      ability.can :read, TaskConnection, source: Ability::EXTERNAL_OPTIONS

      [TaskClosure, TaskComment, TaskReopening,
       Progression, Review].each do |model_name|
        ability.can :read, model_name, task: Ability::EXTERNAL_OPTIONS
      end
    end

    def activate_visible_read_abilities
      ability.can :read, Task, project: Ability::VISIBLE_PROJECT_OPTIONS
      ability.can :read, TaskConnection, source: Ability::VISIBLE_OPTIONS

      [TaskClosure, TaskComment, TaskReopening,
       Progression, Review].each do |model_name|
        ability.can :read, model_name, task: Ability::VISIBLE_OPTIONS
      end
    end

    def activate_invisible_read_abilities
      [Task, TaskClosure, TaskConnection, TaskComment, TaskReopening,
       Progression, Review].each do |model_name|
        ability.can :read, model_name
      end
      ability.can :read, TaskAssignee, assignee_id: user_id
      ability.can %i[read destroy], TaskNotification, user_id: user_id
    end

    def activate_visible_task_abilities
      ability.can %i[create update], Task,
                  user_id: user_id, project: Ability::VISIBLE_PROJECT_OPTIONS
      ability.can :assign, Task,
                  closed: false, project: Ability::VISIBLE_PROJECT_OPTIONS
      ability.can :move, Task
      ability.can :create, TaskClosure,
                  user_id: user_id,
                  task: Ability::VISIBLE_OPTIONS.merge(closed: false,
                                                       user_id: user_id)
    end

    def activate_visible_review_abilities
      ability.can %i[approve disapprove], Review,
                  approved: nil, task: Ability::VISIBLE_OPTIONS
      ability.can %i[create update], TaskConnection,
                  user_id: user_id, source: Ability::VISIBLE_OPTIONS
      ability.can :destroy, TaskConnection, source: Ability::VISIBLE_OPTIONS
      ability.can :create, TaskReopening,
                  user_id: user_id,
                  task: Ability::VISIBLE_OPTIONS.merge(closed: true)
    end

    def activate_invisible_task_review_abilities
      user_options = { user_id: user_id }

      ability.can :destroy, Review,
                  user_options.merge(approved: nil, task: { closed: false })
      ability.can %i[approve disapprove], Review, approved: nil
      ability.can :create, TaskClosure,
                  user_options.merge(task: { closed: false })
      ability.can :create, TaskConnection, user_options
      ability.can :create, TaskReopening,
                  user_options.merge(task: { closed: true })
      ability.can :update, TaskConnection, user_options
    end
end
