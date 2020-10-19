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
    return false unless employee?

    admin? || record.user == user
  end

  def update?
    return false unless employee?

    admin? || record.user == user
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
