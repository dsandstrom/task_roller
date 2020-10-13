# frozen_string_literal: true

# TODO: authorize issue on visible

class IssuePolicy < ApplicationPolicy
  def index?
    employee?
  end

  def show?
    employee?
  end

  def create?
    employee?
  end

  def new?
    employee?
  end

  def edit?
    admin? || record.user == user
  end

  def update?
    admin? || record.user == user
  end

  def destroy?
    admin?
  end

  def open?
    admin?
  end

  def close?
    admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
