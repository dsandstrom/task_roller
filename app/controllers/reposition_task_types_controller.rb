# frozen_string_literal: true

class RepositionTaskTypesController < ApplicationController
  before_action :set_task_type

  def update
    notice =
      if @task_type.valid? && @task_type.reposition(params[:sort])
        "#{@task_type.name} was successfully moved #{params[:sort]}."
      else
        'Task Type was successfully moved.'
      end
    redirect_to roller_types_url, notice: notice
  end
end
