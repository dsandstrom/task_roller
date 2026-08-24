class TaskTypeMigrationsController < ApplicationController
  load_and_authorize_resource :task_type
  before_action :build_task_type_options, only: :new

  def new; end

  def create
    @new_task_type = TaskType.find(task_type_params[:new_task_type_id])
    # rubocop:disable Rails/SkipsModelValidations
    Task.where(task_type: @task_type)
        .update_all(task_type_id: @new_task_type.id)
    # rubocop:enable Rails/SkipsModelValidations
    redirect_to issue_types_path, notice: notice
  rescue ActiveRecord::RecordNotFound
    build_task_type_options
    @task_type.errors.add(:new_task_type_id, 'not found')
    render :new
  end

  private

    def task_type_params
      params.expect(task_type: %i[new_task_type_id])
    end

    def build_task_type_options
      @task_types = TaskType.where.not(id: @task_type.id)
    end

    def notice
      "'#{@task_type.name}' tasks where successfully migrated to " \
        "'#{@new_task_type.name}' type"
    end
end
