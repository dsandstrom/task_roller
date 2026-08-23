class IssuesController < ApplicationController
  load_and_authorize_resource :project, only: %i[destroy]
  load_and_authorize_resource through: :project, only: %i[destroy]
  load_and_authorize_resource only: %i[show create edit update]
  authorize_resource only: :index

  before_action :set_new_form_options, only: :new
  before_action :set_edit_form_options, only: :edit
  before_action :issue_types_exist?, only: %i[new edit]
  before_action :projects_exist?, only: :new

  def index
    @source = build_source
    authorize! :read, @source

    @issues = build_issues.accessible_by(current_ability)
                          .with_notifications(current_user, order_by: order_by)
                          .filter_by(build_filters).page(params[:page])
  end

  def show
    @user = @issue.user
    @task = @issue.tasks.find(params.expect(:task_id)) if params[:task_id]

    set_issue_variables
  end

  def new
    authorize! :create, Issue

    @issue = build_issue
    @project = @issue.project if @issue.project
  end

  def edit; end

  def create
    if @issue.save
      IssueSubscriptionsJob.perform_later(@issue)
      @issue.update_status(current_user)
      redirect_to @issue, success: 'Issue was successfully created.'
    else
      set_new_form_options
      render :new
    end
  end

  def update
    if @issue.update(issue_update_params)
      @issue.update_status(current_user)
      redirect_to @issue, success: 'Issue was successfully updated.'
    else
      set_edit_form_options
      render :edit
    end
  end

  def destroy
    @issue.destroy
    redirect_to @project, success: 'Issue was successfully destroyed.'
  end

  private

    def issue_params
      params.expect(issue: %i[summary description issue_type_id project_id])
    end

    def issue_update_params
      params.expect(issue: %i[summary description issue_type_id])
    end

    def set_new_form_options
      @issue_types = IssueType.all
      @project_options = build_project_options
    end

    def set_edit_form_options
      @issue_types = IssueType.all
    end

    def issue_types_exist?
      return true if @issue_types&.any?

      redirect_url = can?(:create, IssueType) ? issue_types_url : root_url
      redirect_to redirect_url, alert: 'App Error: Issue Types are required'
      false
    end

    def projects_exist?
      return true if @project_options&.any?

      redirect_to root_url, alert: 'App Error: Projects are required'
      false
    end

    def build_source
      if params[:user_id]
        User.find(params.expect(:user_id))
      elsif params[:project_id]
        Project.find(params.expect(:project_id))
      else
        Category.find(params.expect(:category_id))
      end
    end

    def build_issues
      issues = @source.issues
      if @source.respond_to?(:totally_visible?)
        issues = issues.all_visible if @source.totally_visible?
      elsif @source.respond_to?(:visible?)
        issues = issues.all_visible if @source.visible?
      elsif @source.is_a?(User)
        issues = issues.all_visible
      end
      issues
    end

    def build_issue
      current_user.issues.build(issue_type_id: @issue_types.first.id,
                                project_id: params[:project_id])
    end

    def build_project_options
      Category.all_visible.accessible_by(current_ability).map do |category|
        projects = category.projects.all_visible
                           .accessible_by(current_ability).map do |project|
          [project.name, project.id]
        end

        [category.name, projects] if projects.any?
      end.compact
    end

    def set_issue_variables
      @project = @issue.project
      @comments = @issue.comments.includes(:user)
      @notifications = @issue.notifications.where(user_id: current_user_id)
                             .where(event: %w[new status])
                             .order(created_at: :asc)
      @source_connection = @issue.source_connection
      @duplicates = @issue.duplicates
      @source_connection = @issue.source_connection
      @subscription = @issue.issue_subscriptions
                            .find_or_initialize_by(user_id: current_user_id)
    end
end
