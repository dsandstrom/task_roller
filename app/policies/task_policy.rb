# frozen_string_literal: true

# TODO: authorize task on visible
# TODO: lock edit after closed except admin

class TaskPolicy < ApplicationPolicy
  def index?
    employee?
  end

  def show?
    employee?
  end

  def create?
    user.admin? || user.reviewer?
  end

  def new?
    user.admin? || user.reviewer?
  end

  # maybe allow any reviewer
  def edit?
    employee? && (admin? || record.user_id == user.id)
  end

  def update?
    employee? && (admin? || record.user_id == user.id)
  end

  def open?
    admin?
  end

  def close?
    admin?
  end

  def assign?
    user.admin? || user.reviewer?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
