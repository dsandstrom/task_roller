# frozen_string_literal: true

class CategoryAbility
  CLASSES = [CategoryTasksSubscription, CategoryIssuesSubscription].freeze

  attr_accessor :ability, :user

  def initialize(attrs)
    %i[ability user].each do |key|
      send("#{key}=", attrs[key])
    end
  end

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

    def activate_reviewer
      ability.can :read, Category
      ability.can %i[create read update], Category
      CLASSES.each do |name|
        ability.can :manage, name, user_id: user.id,
                                   category: Ability::VISIBLE_CATEGORY_OPTIONS
      end
    end

    def activate_admin
      ability.can :destroy, Category
    end

    def activate_worker
      ability.can :read, Category, Ability::VISIBLE_CATEGORY_OPTIONS
      CLASSES.each do |name|
        ability.can :manage, name, user_id: user.id,
                                   category: Ability::VISIBLE_CATEGORY_OPTIONS
      end
    end

    def activate_reporter
      ability.can :read, Category, Ability::EXTERNAL_CATEGORY_OPTIONS
      CLASSES.each do |name|
        ability.can :manage, name, user_id: user.id,
                                   category: Ability::EXTERNAL_CATEGORY_OPTIONS
      end
    end
end
