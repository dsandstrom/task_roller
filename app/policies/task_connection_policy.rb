# frozen_string_literal: true

class TaskConnectionPolicy < ApplicationPolicy
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
    admin? || user.reviewer?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
