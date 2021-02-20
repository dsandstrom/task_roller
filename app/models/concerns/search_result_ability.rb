# frozen_string_literal: true

class SearchResultAbility < BaseAbility
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

      ability.can :update, SearchResult
      ability.can :destroy, SearchResult
    end

    def activate_reviewer
      ability.can %i[create update], SearchResult,
                  user_id: user_id, class_name: 'Task',
                  project: Ability::VISIBLE_PROJECT_OPTIONS
      ability.can %i[create update], SearchResult,
                  user_id: user_id, class_name: 'Issue',
                  project: Ability::VISIBLE_PROJECT_OPTIONS
      ability.can :read, SearchResult
    end

    def activate_worker
      ability.can %i[create update], SearchResult,
                  user_id: user_id, class_name: 'Issue',
                  project: Ability::VISIBLE_PROJECT_OPTIONS
      ability.can :read, SearchResult, project: Ability::VISIBLE_PROJECT_OPTIONS
    end

    def activate_reporter
      ability.can %i[create update], SearchResult,
                  user_id: user_id, class_name: 'Issue',
                  project: Ability::EXTERNAL_PROJECT_OPTIONS
      ability.can :read, SearchResult,
                  project: Ability::EXTERNAL_PROJECT_OPTIONS
    end
end
