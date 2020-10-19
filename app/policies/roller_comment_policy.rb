# frozen_string_literal: true

class RollerCommentPolicy < ApplicationPolicy
  def index?
    employee?
  end

  def show?
    employee?
  end

  def new?
    employee?
  end

  def create?
    employee?
  end

  def edit?
    return false unless employee?

    admin? || record.user == user
  end

  def update?
    return false unless employee?

    admin? || record.user == user
  end

  def destroy?
    admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
