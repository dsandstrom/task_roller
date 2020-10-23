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

    record.task.assignee_ids.include?(user.id)
  end

  def finish?
    return false unless employee? && record&.user

    record.user_id == user.id
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
