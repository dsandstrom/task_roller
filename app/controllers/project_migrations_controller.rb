class ProjectMigrationsController < ApplicationController
  load_resource :project, except: :index
  before_action :authorize_migrate
  before_action :set_project_options, only: :new

  def index
    @categories = Category.with_projects
  end

  def new; end

  def create
    @new_project = Project.find(project_params[:migration_id])
    # rubocop:disable Rails/SkipsModelValidations
    Task.where(project: @project)
        .update_all(project_id: @new_project.id)
    Issue.where(project: @project)
         .update_all(project_id: @new_project.id)
    # rubocop:enable Rails/SkipsModelValidations
    redirect_to @project.category, notice: notice
  rescue ActiveRecord::RecordNotFound
    set_project_options
    @project.errors.add(:new_project_id, 'not found')
    render :new
  end

  private

    def authorize_migrate
      authorize! :migrate, (@project || Project)
    end

    def project_params
      params.expect(project: %i[migration_id])
    end

    def set_project_options
      @project_options = build_all_project_options(@project)
      return if @project_options.any?

      raise ApplicationError::MissingProjects, 'Another project is required'
    end

    def notice
      "Issues and Tasks from '#{@project.name}' were successfully migrated " \
        "to '#{@new_project.name}'"
    end
end
