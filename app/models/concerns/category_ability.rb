class CategoryAbility < BaseAbility
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
      ability.can :destroy, Category
    end

    def activate_reviewer
      ability.can :read, Category
      ability.can %i[create read update], Category
    end

    def activate_worker
      ability.can :read, Category, Ability::VISIBLE_CATEGORY_OPTIONS
    end

    def activate_reporter
      ability.can :read, Category, Ability::EXTERNAL_CATEGORY_OPTIONS
    end
end
