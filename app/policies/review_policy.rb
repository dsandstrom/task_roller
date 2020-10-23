# frozen_string_literal: true

class ReviewPolicy < ApplicationPolicy
  def index?
    employee?
  end

  def show?
    employee?
  end

  def new?
    return false unless employee? && record&.task && user

    record.task.assignee_ids.include?(user.id)
  end

  def create?
    return false unless employee? && record&.task && user

    record.task.assignee_ids.include?(user.id)
  end

  def destroy?
    return false unless record && user

    record.pending? && record.task&.open? && record.user_id == user.id
  end

  def approve?
    admin? || user&.reviewer?
  end

  def disapprove?
    admin? || user&.reviewer?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
