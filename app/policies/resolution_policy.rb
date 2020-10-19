# frozen_string_literal: true

class ResolutionPolicy < ApplicationPolicy
  def index?
    employee?
  end

  def show?
    employee?
  end

  def new?
    return false unless employee? && user && record&.issue&.unresolved?

    record.issue.user == user
  end

  # TODO: change to addressed?
  def create?
    return false unless employee? && user && record&.issue&.unresolved?

    record.issue.user == user
  end

  def approve?
    create?
  end

  def disapprove?
    create?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
