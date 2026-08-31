class RepositionIssueTypesController < ApplicationController
  load_and_authorize_resource class: 'IssueType', instance_name: :issue_type

  def update
    if @issue_type.valid? && @issue_type.reposition(params[:sort])
      redirect_to issue_types_url,
                  notice: "#{@issue_type.name} was successfully moved " \
                          "#{params[:sort]}."
    else
      redirect_to issue_types_url, notice: 'Issue Type was unable to be moved.'
    end
  end
end
