# frozen_string_literal: true

# TODO: maybe assign reviewers/workers to categories and its projects
# might cause too much user juggling

class CategoryPolicy < ApplicationPolicy
  def index?
    employee?
  end

  def show?
    employee?
  end

  def create?
    admin?
  end

  def new?
    admin?
  end

  def update?
    admin? || reviewer?
  end

  def edit?
    admin? || reviewer?
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
