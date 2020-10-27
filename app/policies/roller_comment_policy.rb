# frozen_string_literal: true

# TODO: lock editing after record.issue/task closed except admin

class RollerCommentPolicy < ApplicationPolicy
  def index?
    employee?
  end

  def show?
    employee?
  end

  def new?
    employee?
  end

  def create?
    employee?
  end

  # TODO: admin need to edit? maybe just destroy
  def edit?
    return false unless employee?

    admin? || record.user_id == user.id
  end

  def update?
    return false unless employee?

    admin? || record.user_id == user.id
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
