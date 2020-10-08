# frozen_string_literal: true

class CategoryPolicy < ApplicationPolicy
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
    admin? || user.reviewer?
  end

  def edit?
    admin? || user.reviewer?
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
