# frozen_string_literal: true

class ProgressionsController < ApplicationController
  load_and_authorize_resource :task
  load_and_authorize_resource through: :task

  def new; end

  def create
    if @progression.save
      @task.update_status
      redirect_back_or_to(@task,
                          notice: 'Progress successfully started on task.')
    else
      render :new
    end
  end

  def destroy
    @progression.destroy
    @task.update_status
    redirect_to @task, notice: 'Progression was successfully removed.'
  end

  def finish
    if @progression.finish
      @task.update_status
      redirect_back_or_to(@task, notice: 'Progress was successfully finished.')
    else
      render :edit
    end
  end
end
