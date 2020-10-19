# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    employee?
  end

  def show?
    employee?
  end

  def create?
    admin?
  end

  def new?
    admin?
  end

  def update?
    return false unless employee?

    admin? || user == record
  end

  def edit?
    return false unless employee?

    admin? || user == record
  end

  def destroy?
    admin? && user != record
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
