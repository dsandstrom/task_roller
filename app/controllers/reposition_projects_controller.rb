class RepositionProjectsController < ApplicationController
  load_and_authorize_resource class: 'Project', instance_name: :project

  def update
    @project.new_position = project_params[:new_position].to_i

    if @project.valid? && @project.reposition
      update_success
    else
      update_failure
    end
  end

  private

    def project_params
      params.expect(project: %i[new_position])
    end

    def update_success
      respond_to do |format|
        format.html do
          redirect_to reposition_categories_path,
                      notice: "#{@project.name} was successfully moved."
        end
        format.json { head :ok }
      end
    end

    def update_failure
      respond_to do |format|
        format.html do
          redirect_to reposition_categories_path,
                      notice: "#{@project.name} was unable to be moved."
        end
        format.json { head :unprocessable_content }
      end
    end
end
