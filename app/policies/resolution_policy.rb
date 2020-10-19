# frozen_string_literal: true

class ResolutionPolicy < ApplicationPolicy
  def index?
    employee?
  end

  def show?
    employee?
  end

  def new?
    return false unless employee? && user && record&.issue
    return false if record.issue.resolved?

    record.issue.user == user
  end

  def create?
    new?
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
