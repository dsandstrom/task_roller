# frozen_string_literal: true

# TODO: allow searching by text (to see if reported)
# TODO: when closed, lock updating description
# TODO: add issue type filter

class IssuesController < ApplicationController
  load_and_authorize_resource :project, only: %i[new create]
  load_and_authorize_resource through: :project, only: %i[new create]
  load_and_authorize_resource except: %i[index new create]
  before_action :set_parent, only: :index
  before_action :set_category_and_project, except: :index
  before_action :set_form_options, only: %i[new edit]
  before_action :check_for_issue_types, only: :new

  def index
    authorize! :read, Issue

    set_issues
    set_subscription
  end

  def show
    @comments = @issue.comments.includes(:user)
    @comment = @issue.comments.build
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
      redirect_url =
        can?(:create, IssueType) ? issue_types_url : project_url(@project)
      redirect_to redirect_url, alert: 'App Error: Issue Types are required'
    end
  end

  def edit; end

  def create
    if @issue.save
      @issue.subscribe_users
      redirect_to issue_url(@issue), success: 'Issue was successfully created.'
    else
      set_form_options
      render :new
    end
  end

  def update
    if @issue.update(issue_params)
      redirect_to issue_url(@issue), success: 'Issue was successfully updated.'
    else
      set_form_options
      render :edit
    end
  end

  def destroy
    @issue.destroy
    redirect_to project_url(@project),
                success: 'Issue was successfully destroyed.'
  end

  def open
    if @issue.reopen
      @issue.subscribe_user(current_user)
      redirect_to issue_url(@issue), success: 'Issue was successfully opened.'
    else
      set_form_options
      render :edit
    end
  end

  def close
    if @issue.close
      @issue.subscribe_user(current_user)
      redirect_to issue_url(@issue), success: 'Issue was successfully closed.'
    else
      set_form_options
      render :edit
    end
  end

  private

    def check_for_issue_types
      return true if @issue_types&.any?

      redirect_url =
        can?(:create, IssueType) ? issue_types_url : project_url(@project)
      redirect_to redirect_url, alert: 'App Error: Issue Types are required'
      false
    end

    def set_parent
      if params[:user_id]
        @user = User.find(params[:user_id])
      elsif params[:project_id]
        @project = Project.find(params[:project_id])
      else
        @category = Category.find(params[:category_id])
      end
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
      @issues =
        if @user
          @issues = @user.issues
        elsif @project
          @project.issues
        else
          @category.issues
        end
      @issues = @issues.filter_by(build_filters).page(params[:page])
    end

    def set_subscription
      @subscription =
        if @project
          @project.issues_subscription(current_user, init: true)
        elsif @category
          @category.issues_subscription(current_user, init: true)
        end
    end

    def issue_params
      params.require(:issue).permit(:summary, :description, :issue_type_id)
    end
end
