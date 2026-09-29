class ProjectAbility < BaseAbility
  def activate
    if user.admin? || user.reviewer?
      activate_reviewer
    elsif user.worker?
      activate_worker
    else
      activate_reporter
    end

    activate_admin if user.admin?
  end

  private

    def activate_admin
      ability.can :destroy, Project
    end

    def activate_reviewer
      ability.can :read, Project
      ability.can :create, Project, category: { visible: true }
      ability.can %i[read update], Project
    end

    def activate_worker
      ability.can :read, Project, Ability::VISIBLE_PROJECT_OPTIONS
    end

    def activate_reporter
      ability.can :read, Project, Ability::EXTERNAL_PROJECT_OPTIONS
    end
end
