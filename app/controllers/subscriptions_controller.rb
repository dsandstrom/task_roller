# frozen_string_literal: true

# TODO: show category & project subscriptions
# TODO: separate archived issues/tasks subscriptions

class SubscriptionsController < ApplicationController
  authorize_resource :issue_subscription
  load_resource :active_assignments, through: :current_user, singleton: true
  load_resource :open_tasks, through: :current_user, singleton: true
  load_resource :unresolved_issues, through: :current_user, singleton: true

  def index
    @unresolved_issues = @unresolved_issues.accessible_by(current_ability)
    @open_tasks = @open_tasks.accessible_by(current_ability)
    @active_assignments = @active_assignments.accessible_by(current_ability)
  end
end
