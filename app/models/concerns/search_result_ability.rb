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
      activate_worker
      activate_invisible_read_abilities
    end

    def activate_worker
      activate_visible_abilities
    end

    def activate_reporter
      activate_external_abilities
    end

    def activate_visible_abilities
      ability.can %i[create update], SearchResult,
                  user_id: user_id, project: Ability::VISIBLE_PROJECT_OPTIONS
      ability.can :read, SearchResult, project: Ability::VISIBLE_PROJECT_OPTIONS
    end

    def activate_external_abilities
      ability.can %i[create update], SearchResult,
                  user_id: user_id, project: Ability::EXTERNAL_PROJECT_OPTIONS
      ability.can :read, SearchResult,
                  project: Ability::EXTERNAL_PROJECT_OPTIONS
    end

    def activate_invisible_read_abilities
      ability.can :read, SearchResult
    end
end
