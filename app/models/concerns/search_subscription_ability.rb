class SearchSubscriptionAbility < BaseAbility
  def activate
    ability.can :manage, SearchSubscription, user_id: user_id
  end
end
