# frozen_string_literal: true

# TODO: search categories and projects
# TODO: allow searching by id

class SearchesController < ApplicationController
  before_action :authorize_search
  before_action :verify_filters, only: :index

  def index
    @search_results = build_search_results.page(params[:page])
  end

  def new; end

  private

    def filters
      @filters ||= build_filters
    end

    def authorize_search
      authorize! :read, Issue
      authorize! :read, Task
    end

    def verify_filters
      redirect_to :search unless filters&.any? { |_, value| value.present? }
    end

    def build_search_results
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
      SearchResult.accessible_by(current_ability).filter_by(filters)
                  .preload(:project, :user, :issue, :assignees,
                           project: :category)
    end

    def build_tasks
      Task.accessible_by(current_ability).filter_by(filters)
          .preload(:project, :user, :issue, :assignees, project: :category)
    end

    def build_issues
      Issue.accessible_by(current_ability).filter_by(filters)
           .preload(:project, :user, project: :category)
    end
end
