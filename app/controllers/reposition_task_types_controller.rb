class RepositionTaskTypesController < ApplicationController
  load_and_authorize_resource class: 'TaskType', instance_name: :task_type

  def update
    if @task_type.valid? && @task_type.reposition(params[:sort])
      redirect_to issue_types_url,
                  notice: "#{@task_type.name} was successfully moved " \
                          "#{params[:sort]}."
    else
      redirect_to issue_types_url, notice: 'Task Type was unable to be moved.'
    end
  end
end
