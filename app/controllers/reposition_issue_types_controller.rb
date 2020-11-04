# frozen_string_literal: true

class RepositionIssueTypesController < ApplicationController
  load_and_authorize_resource class: 'IssueType', instance_name: :issue_type

  def update
    redirect_to issue_types_url, notice: notice
  end

  private

    def notice
      @notice ||=
        if @issue_type.valid? && @issue_type.reposition(params[:sort])
          "#{@issue_type.name} was successfully moved #{params[:sort]}."
        else
          'Issue Type was successfully moved.'
        end
    end
end
