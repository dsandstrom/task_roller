# frozen_string_literal: true

class RepositionTaskTypesController < ApplicationController
  load_and_authorize_resource class: 'TaskType', instance_name: :task_type

  def update
    redirect_to roller_types_url, notice: notice
  end

  private

    def notice
      @notice ||=
        if @task_type.valid? && @task_type.reposition(params[:sort])
          "#{@task_type.name} was successfully moved #{params[:sort]}."
        else
          'Task Type was successfully moved.'
        end
    end
end
