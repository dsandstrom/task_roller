# frozen_string_literal: true

class UserAbility < BaseAbility
  def activate
    activate_user
    activate_github_account
    return unless user.admin?

    activate_admin
  end

  private

    def activate_user
      ability.can :read, User
      ability.cannot :read, User, employee_type: nil
      ability.can :update, User, id: user_id
      ability.cannot :update, User, employee_type: nil
      ability.can :cancel, User, id: user_id
    end

    def activate_admin
      ability.can :manage, User
      ability.cannot :create, User, employee_type: nil
      ability.cannot %i[destroy cancel promote], User, id: user_id
    end

    def activate_github_account
      ability.can :manage, GithubAccount, user_id: user_id
      ability.can :read, GithubAccount
    end
end
