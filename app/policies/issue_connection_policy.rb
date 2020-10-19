# frozen_string_literal: true

class IssueConnectionPolicy < ApplicationPolicy
  def index?
    employee?
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
    admin? || reviewer?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
