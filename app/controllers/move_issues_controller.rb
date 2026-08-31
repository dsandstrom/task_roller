class MoveIssuesController < ApplicationController
  load_and_authorize_resource :issue
  before_action :authorize_move
  before_action :set_categories

  def edit; end

  def update
    if @issue.update(issue_params)
      redirect_to @issue, notice: 'Issue was successfully moved.'
    else
      render :edit
      set_categories
    end
  end

  private

    def authorize_move
      authorize! :move, @issue
    end

    def issue_params
      params.expect(issue: [:project_id])
    end

    def set_categories
      @categories = Category.accessible_by(current_ability).order(:position)
    end
end
