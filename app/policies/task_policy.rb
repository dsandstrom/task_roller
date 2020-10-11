# frozen_string_literal: true

class TaskPolicy < ApplicationPolicy
  def index?
    employee?
  end

  def show?
    employee?
  end

  def create?
    employee? && (user.admin? || user.reviewer? || user.worker?)
  end

  def new?
    employee? && (user.admin? || user.reviewer? || user.worker?)
  end

  def edit?
    employee? && (admin? || record.user == user)
  end

  def update?
    employee? && (admin? || record.user == user)
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