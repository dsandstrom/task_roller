# frozen_string_literal: true

class ProjectPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    employee?
  end

  def create?
    admin? || reviewer?
  end

  def new?
    admin? || reviewer?
  end

  def update?
    admin? || reviewer?
  end

  def edit?
    admin? || reviewer?
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
