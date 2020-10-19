# frozen_string_literal: true

class ProgressionPolicy < ApplicationPolicy
  def index?
    employee?
  end

  def show?
    employee?
  end

  def new?
    return false unless employee? && record&.task && user

    record.task.assignees.include?(user)
  end

  def create?
    return false unless employee? && record&.task && user

    record.task.assignees.include?(user)
  end

  def edit?
    admin?
  end

  def update?
    admin?
  end

  def finish?
    return false unless employee? && record&.user

    record.user == user
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
