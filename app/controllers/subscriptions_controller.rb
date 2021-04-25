# frozen_string_literal: true

# TODO: show category & project subscriptions

class SubscriptionsController < ApplicationController
  authorize_resource :issue_subscription

  def index
    @subscriptions = build.all_visible.accessible_by(current_ability)
    @subscriptions = @subscriptions.filter_by(filters).page(params[:page])
  end

  private

    def filters
      @filters ||= build_filters
    end

    def build_filters
      temp = super
      temp[:order] = 'count,desc' if temp[:order] == 'updated,desc'
      temp
    end

    def build
      case filters[:type]
      when 'issues'
        build_issues
      when 'tasks'
        build_tasks
      else
        build_issues_and_tasks
      end
    end

    def build_issues_and_tasks
      current_user
        .subscriptions
        .preload(:project, :user, :issue, :assignees, project: :category)
    end

    def build_tasks
      query = 'LEFT OUTER JOIN task_notifications ON '\
              '(task_notifications.task_id = tasks.id AND '\
              "task_notifications.user_id = #{current_user.id})"
      tasks = current_user.subscribed_tasks
                          .joins(query).select('tasks.*').group(:id)
                          .preload(:project, :user, :issue, :assignees,
                                   project: :category)
      return tasks unless params[:order] == 'updated,desc'

      tasks.order('COUNT(task_notifications.id) DESC')
    end

    def build_issues
      query = 'LEFT OUTER JOIN issue_notifications ON '\
              '(issue_notifications.issue_id = issues.id AND '\
              "issue_notifications.user_id = #{current_user.id})"
      issues = current_user.subscribed_issues
                           .joins(query).select('issues.*').group(:id)
                           .preload(:project, :user, project: :category)
      return issues unless params[:order] == 'updated,desc'

      issues.order('COUNT(issue_notifications.id) DESC')
    end
end
