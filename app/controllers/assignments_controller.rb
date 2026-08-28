class AssignmentsController < ApplicationController
  load_and_authorize_resource :user, only: :index
  load_and_authorize_resource through: :user, class: 'Task', only: :index
  load_and_authorize_resource :task, only: :new
  before_action :authorize_task, only: :new
  before_action :load_and_authorize_task, only: %i[edit update]

  def index
    @assignments = @assignments.all_visible.accessible_by(current_ability)
                               .filter_by(build_filters).page(params[:page])
  end

  def new
    @assignees = @task.assignees.includes(:progressions)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def update
    if @task.update(task_params)
      update_task_status

      respond_to do |format|
        format.html { redirect_to @task, notice: update_notice }
        format.turbo_stream { redirect_to @task }
      end
    else
      render :edit
    end
  end

  private

    def authorize_task
      authorize! :assign, @task
    end

    def load_and_authorize_task
      @task = Task.find(params.expect(:id))
      authorize_task
    end

    def task_params
      params.expect(task: { assignee_ids: [] })
    end

    def update_task_status
      @task.subscribe_assignees
      @task.update_status
    end

    def update_notice
      'Task was successfully reassigned.'
    end
end
