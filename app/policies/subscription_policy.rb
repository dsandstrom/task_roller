# frozen_string_literal: true

class SubscriptionPolicy < ApplicationPolicy
  def index?
    employee?
  end

  def new?
    employee?
  end

  def create?
    employee?
  end

  def show?
    employee? && record.user_id == user.id
  end

  def edit?
    employee? && record.user_id == user.id
  end

  def update?
    employee? && record.user_id == user.id
  end

  def destroy?
    employee? && record.user_id == user.id
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
