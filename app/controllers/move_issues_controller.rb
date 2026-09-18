class MoveIssuesController < ApplicationController
  load_and_authorize_resource :issue
  before_action :authorize_move
  before_action :set_project_options

  def edit; end

  def update
    if @issue.update(issue_params)
      redirect_to @issue, notice: 'Issue was successfully moved.'
    else
      render :edit
      set_project_options
    end
  end

  private

    def authorize_move
      authorize! :move, @issue
    end

    def issue_params
      params.expect(issue: [:project_id])
    end

    def set_project_options
      @project_options = build_all_project_options(@issue.project)
      return if @project_options.any?

      raise ApplicationError::MissingProjects, 'Another projects is required'
    end
end
