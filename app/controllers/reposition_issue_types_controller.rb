class RepositionIssueTypesController < ApplicationController
  load_and_authorize_resource class: 'IssueType', instance_name: :issue_type

  def update
    @issue_type.new_position = issue_type_params[:new_position].to_i

    if @issue_type.valid? && @issue_type.reposition
      update_success
    else
      update_failure
    end
  end

  private

    def issue_type_params
      params.expect(issue_type: %i[new_position])
    end

    def update_success
      respond_to do |format|
        format.html do
          redirect_to issue_types_url,
                      notice: "#{@issue_type.name} was successfully moved."
        end
        format.json { head :ok }
      end
    end

    def update_failure
      respond_to do |format|
        format.html do
          redirect_to issue_types_url,
                      notice: "#{@issue_type.name} was unable to be moved."
        end
        format.json { head :unprocessable_content }
      end
    end
end
