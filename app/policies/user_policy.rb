# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    user.employee?
  end

  def show?
    user.employee?
  end

  def create?
    admin?
  end

  def new?
    admin?
  end

  def update?
    admin? || user == record
  end

  def edit?
    admin? || user == record
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
