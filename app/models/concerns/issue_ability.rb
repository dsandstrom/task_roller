# frozen_string_literal: true

class IssueAbility < BaseAbility
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

      ability.can :manage, IssueType

      [Issue, IssueComment, Resolution].each do |model_name|
        ability.can :update, model_name
      end

      [Issue, IssueComment, IssueConnection, IssueClosure,
       IssueReopening, Resolution].each do |model_name|
        ability.can :destroy, model_name
      end
    end

    def activate_reviewer
      activate_visible_abilities
      activate_visible_read_abilities
      activate_visible_review_abilities
      activate_invisible_read_abilities
    end

    def activate_worker
      activate_visible_abilities
      activate_visible_read_abilities
    end

    def activate_reporter
      activate_external_abilities
      activate_external_read_abilities
    end

    def activate_visible_abilities
      options = { user_id: user_id, issue: Ability::VISIBLE_OPTIONS }

      ability.can %i[create update], Issue,
                  user_id: user_id, project: Ability::VISIBLE_PROJECT_OPTIONS
      ability.can %i[create update], IssueComment, options
      ability.can :manage, IssueNotification, options
      ability.can :manage, IssueSubscription, options
      ability.can :create, Resolution,
                  user_id: user_id,
                  issue: Ability::VISIBLE_OPTIONS.merge(user_id: user_id)
    end

    def activate_visible_read_abilities
      ability.can :read, Issue, project: Ability::VISIBLE_PROJECT_OPTIONS
      ability.can :read, IssueConnection, source: Ability::VISIBLE_OPTIONS

      [IssueClosure, IssueComment, IssueReopening,
       Resolution].each do |model_name|
        ability.can :read, model_name, issue: Ability::VISIBLE_OPTIONS
      end
    end

    def activate_external_abilities
      options = { user_id: user_id, issue: Ability::EXTERNAL_OPTIONS }

      ability.can %i[create update], Issue,
                  user_id: user_id, project: Ability::EXTERNAL_PROJECT_OPTIONS
      ability.can %i[create update], IssueComment, options
      ability.can :manage, IssueNotification, options
      ability.can :manage, IssueSubscription, options
      ability.can :create, Resolution,
                  user_id: user_id,
                  issue: Ability::EXTERNAL_OPTIONS.merge(user_id: user_id)
    end

    def activate_external_read_abilities
      ability.can :read, Issue, project: Ability::EXTERNAL_PROJECT_OPTIONS
      ability.can :read, IssueConnection, source: Ability::EXTERNAL_OPTIONS

      [IssueClosure, IssueComment, IssueReopening,
       Resolution].each do |model_name|
        ability.can :read, model_name, issue: Ability::EXTERNAL_OPTIONS
      end
    end

    def activate_invisible_read_abilities
      [Issue, IssueClosure, IssueConnection, IssueComment, IssueReopening,
       Resolution].each do |model_name|
        ability.can :read, model_name
      end
      ability.can %i[read destroy], IssueNotification, user_id: user_id
    end

    def activate_invisible_abilities
      ability.can :create, IssueConnection, user_id: user_id
      ability.can :create, IssueClosure,
                  user_id: user_id, issue: { closed: false }
      ability.can :create, IssueReopening,
                  user_id: user_id, issue: { closed: true }
      ability.can :update, IssueConnection, user_id: user_id
    end

    def activate_visible_review_abilities
      ability.can :move, Issue
      ability.can :create, IssueClosure,
                  user_id: user_id,
                  issue: Ability::VISIBLE_OPTIONS.merge(closed: false)
      ability.can %i[create update], IssueConnection,
                  user_id: user_id, source: Ability::VISIBLE_OPTIONS
      ability.can :destroy, IssueConnection, source: Ability::VISIBLE_OPTIONS
      ability.can :create, IssueReopening,
                  user_id: user_id,
                  issue: Ability::VISIBLE_OPTIONS.merge(closed: true)
    end
end
