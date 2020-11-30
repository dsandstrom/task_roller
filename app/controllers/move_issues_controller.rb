# frozen_string_literal: true

class MoveIssuesController < ApplicationController
  load_and_authorize_resource :issue
  before_action :authorize_move

  def edit; end

  def update
    if @issue.update(issue_params)
      redirect_to @issue, notice: 'Issue was successfully moved.'
    else
      render :edit
    end
  end

  private

    def authorize_move
      authorize! :move, @issue
    end

    def issue_params
      params.require(:issue).permit(:project_id)
    end
end
