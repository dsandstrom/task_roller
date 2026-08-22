class MoveTasksController < ApplicationController
  load_and_authorize_resource :task, only: %i[edit update]
  before_action :authorize_move, only: %i[edit update]
  before_action :authorize_create, only: %i[new create]
  before_action :set_form_options, only: %i[new create]
  before_action :set_task, only: :create

  def new
    @task = current_user.tasks.build
  end

  def edit; end

  def create
    if @task.project
      authorize! :create, @task

      respond_to do |format|
        format.html { redirect_to new_project_task_path(@task.project) }
        format.turbo_stream { set_task_form_options }
      end
    else
      render :new
    end
  end

  def update
    if @task.update(task_params)
      redirect_to @task, notice: 'Task was successfully moved.'
    else
      render :edit
    end
  end

  private

    def authorize_move
      authorize! :move, @task
    end

    def authorize_create
      authorize! :create, Task
    end

    def task_params
      params.expect(task: [:project_id])
    end

    def new_task_params
      params.expect(task: [:project_id, :summary, :description, :task_type_id,
                           { assignee_ids: [] }])
    end

    def set_form_options
      @project_options = build_project_options
    end

    def set_task
      normalize_assignee_ids
      @task = current_user.tasks.build(new_task_params)
    end

    def set_task_form_options
      @task_types = TaskType.all
      @task.task_type ||= @task_types.first
      @assignee_options = build_assignee_options
      @issue_options = build_issue_options
    end

    # javascript copies the ids to the hidden field strangely
    # eg. ["16, 17"] instead of ["16", "17"]
    def normalize_assignee_ids
      assignee_ids = params[:task][:assignee_ids]
      return unless assignee_ids.present? && assignee_ids.size == 1

      # rubocop:disable Rails/StrongParametersExpect
      params[:task][:assignee_ids] = assignee_ids[0].split(/,\s?/)
      # rubocop:enable Rails/StrongParametersExpect
    end
end
