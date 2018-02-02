# frozen_string_literal: true

class RepositionIssueTypesController < ApplicationController
  before_action :set_issue_type

  def update
    notice =
      if @issue_type.valid? && @issue_type.reposition(params[:sort])
        "#{@issue_type.name} was successfully moved #{params[:sort]}."
      else
        'Issue Type was successfully moved.'
      end
    redirect_to roller_types_url, notice: notice
  end
end
