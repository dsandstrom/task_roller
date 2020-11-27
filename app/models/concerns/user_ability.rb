# frozen_string_literal: true

class UserAbility
  attr_accessor :ability, :user

  def initialize(attrs)
    %i[ability user].each do |key|
      send("#{key}=", attrs[key])
    end
  end

  def activate
    ability.can :read, User
    ability.cannot :read, User, employee_type: nil
    ability.can :update, User, id: user.id
    ability.cannot :update, User, employee_type: nil
    return unless user.admin?

    activate_admin
  end

  private

    def activate_admin
      ability.can :manage, User
      ability.cannot :create, User, employee_type: nil
      ability.cannot :destroy, User, id: user.id
    end
end
