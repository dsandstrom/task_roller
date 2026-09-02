class RepositionTaskTypesController < ApplicationController
  load_and_authorize_resource class: 'TaskType', instance_name: :task_type

  def update
    @task_type.new_position = task_type_params[:new_position].to_i

    if @task_type.valid? && @task_type.reposition
      update_success
    else
      update_failure
    end
  end

  private

    def task_type_params
      params.expect(task_type: %i[new_position])
    end

    def update_success
      respond_to do |format|
        format.html do
          redirect_to issue_types_url,
                      notice: "#{@task_type.name} was successfully moved."
        end
        format.json { head :ok }
      end
    end

    def update_failure
      respond_to do |format|
        format.html do
          redirect_to issue_types_url,
                      notice: "#{@task_type.name} was unable to be moved."
        end
        format.json { head :unprocessable_content }
      end
    end
end
