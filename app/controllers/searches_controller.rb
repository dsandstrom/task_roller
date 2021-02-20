# frozen_string_literal: true

class SearchesController < ApplicationController
  PER_PAGE = 10
  before_action :authorize_search
  before_action :verify_filters, only: :index

  def index
    @results = Kaminari.paginate_array(issues_and_tasks).page(params[:page])
                       .per(PER_PAGE)
  end

  def new; end

  private

    def issues_and_tasks
      @issues_and_tasks ||=
        case filters[:type]
        when 'issues'
          build_issues
        when 'tasks'
          build_tasks
        else
          combined_sort(build_tasks + build_issues)
        end
    end

    # TODO: use union?
    # TODO: add issue/task filter
    # TODO: show other filters if issue/task set
    def combined_sort(items)
      items.sort do |a, b|
        case filters[:order]
        when 'created,asc'
          a.created_at <=> b.created_at
        when 'created,desc'
          b.created_at <=> a.created_at
        when 'updated,asc'
          a.updated_at <=> b.updated_at
        else
          b.updated_at <=> a.updated_at
        end
      end
    end

    def authorize_search
      authorize! :read, Issue
      authorize! :read, Task
    end

    def filters
      @filters ||= build_filters
    end

    def verify_filters
      redirect_to :search unless filters&.any? { |_, value| value.present? }
    end

    def build_tasks
      Task.accessible_by(current_ability).filter_by(filters)
    end

    def build_issues
      Issue.accessible_by(current_ability).filter_by(filters)
    end
end