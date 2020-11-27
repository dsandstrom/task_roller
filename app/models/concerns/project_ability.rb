# frozen_string_literal: true

class ProjectAbility
  CLASSES = [ProjectTasksSubscription, ProjectIssuesSubscription].freeze

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
      ability.can :read, Project
      ability.can %i[create read update], Project
      CLASSES.each do |name|
        ability.can :manage, name, user_id: user.id,
                                   project: Ability::VISIBLE_PROJECT_OPTIONS
      end
    end

    def activate_admin
      ability.can :destroy, Project
    end

    def activate_worker
      ability.can :read, Project, Ability::VISIBLE_PROJECT_OPTIONS
      CLASSES.each do |name|
        ability.can :manage, name, user_id: user.id,
                                   project: Ability::VISIBLE_PROJECT_OPTIONS
      end
    end

    def activate_reporter
      ability.can :read, Project, Ability::EXTERNAL_PROJECT_OPTIONS
      CLASSES.each do |name|
        ability.can :manage, name, user_id: user.id,
                                   project: Ability::EXTERNAL_PROJECT_OPTIONS
      end
    end
end
