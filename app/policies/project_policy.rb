# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def index?
    employee?
  end

  def show?
    employee?
  end

  def create?
    admin? || user.reviewer?
  end

  def new?
    admin? || user.reviewer?
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
