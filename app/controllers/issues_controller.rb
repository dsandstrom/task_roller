# frozen_string_literal: true

# TODO: allow searching by text (to see if reported)
# TODO: when closed, lock updating description
# TODO: add issue type filter

class IssuesController < ApplicationController
  load_and_authorize_resource :project, only: %i[new create]
  load_and_authorize_resource through: :project, only: %i[new create]
  load_and_authorize_resource except: %i[index new create]
  before_action :set_source, :set_issues, only: :index
  before_action :set_category_and_project, except: :index
  before_action :set_form_options, only: %i[new edit]
  before_action :check_for_issue_types, only: :new

  def index
    authorize! :read, Issue

    set_subscription
  end

  def show
    authorize! :read, @project

    @comments = @issue.comments.includes(:user)
    @comment = @issue.comments.build(user_id: current_user.id)
    @issue_subscription =
      @issue.issue_subscriptions.find_or_initialize_by(user_id: current_user.id)
  end

  def new
    if @issue_types&.any?
      @issue = @project.issues.build(issue_type_id: @issue_types.first.id,
                                     user_id: current_user.id)
      authorize! :create, @issue
    else
      # TODO: raise error in ApplicationController and rescue/redirect
      redirect_url = can?(:create, IssueType) ? issue_types_url : @project
      redirect_to redirect_url, alert: 'App Error: Issue Types are required'
    end
  end

  def edit; end

  def create
    if @issue.save
      @issue.subscribe_users
      redirect_to @issue, success: 'Issue was successfully created.'
    else
      set_form_options
      render :new
    end
  end

  def update
    if @issue.update(issue_params)
      redirect_to @issue, success: 'Issue was successfully updated.'
    else
      set_form_options
      render :edit
    end
  end

  def destroy
    @issue.destroy
    redirect_to @project, success: 'Issue was successfully destroyed.'
  end

  private

    def check_for_issue_types
      return true if @issue_types&.any?

      redirect_url = can?(:create, IssueType) ? issue_types_url : root_url
      redirect_to redirect_url, alert: 'App Error: Issue Types are required'
      false
    end

    def set_source
      @source =
        if params[:user_id]
          User.find(params[:user_id])
        elsif params[:project_id]
          Project.find(params[:project_id])
        else
          Category.find(params[:category_id])
        end
      authorize! :read, @source
    end

    def set_category_and_project
      @project ||= @issue.project
      @category ||= @issue.category
      true # rubocop complains about memoization
    end

    def set_form_options
      set_issue_types
    end

    def set_issue_types
      @issue_types = IssueType.all
    end

    def set_issues
      @issues = @source.issues.accessible_by(current_ability)
                       .filter_by(build_filters).page(params[:page])
    end

    def set_subscription
      return unless @source.is_a?(Category) || @source.is_a?(Project)

      @subscription = @source.issues_subscription(current_user, init: true)
    end

    def issue_params
      params.require(:issue).permit(:summary, :description, :issue_type_id)
    end
end
