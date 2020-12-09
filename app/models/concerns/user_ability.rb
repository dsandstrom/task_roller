# frozen_string_literal: true

class UserAbility < BaseAbility
  def activate
    ability.can :read, User
    ability.cannot :read, User, employee_type: nil
    ability.can :update, User, id: user_id
    ability.cannot :update, User, employee_type: nil
    ability.can :cancel, User, id: user_id
    return unless user.admin?

    activate_admin
  end

  private

    def activate_admin
      ability.can :manage, User
      ability.cannot :create, User, employee_type: nil
      ability.cannot %i[destroy cancel promote], User, id: user_id
    end
end
