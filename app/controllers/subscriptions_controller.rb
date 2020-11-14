# frozen_string_literal: true

# TODO: show category & project subscriptions

class SubscriptionsController < ApplicationController
  load_and_authorize_resource :unresolved_issue, through: :current_user,
                                                 only: :index,
                                                 class: 'Issue'
  load_and_authorize_resource :active_assignment, through: :current_user,
                                                  only: :index,
                                                  class: 'Task'
  load_and_authorize_resource :open_task, through: :current_user,
                                          only: :index, class: 'Task'

  def index
    @unresolved_issues = current_user.unresolved_issues
    @open_tasks = current_user.open_tasks
    @active_assignments = current_user.active_assignments
  end
end
