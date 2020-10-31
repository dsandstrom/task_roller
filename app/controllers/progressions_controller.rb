# frozen_string_literal: true

class ProgressionsController < ApplicationController
  load_and_authorize_resource :task
  load_and_authorize_resource through: :task

  def new; end

  def create
    if @progression.save
      redirect_to task_path(@task),
                  notice: 'Progress successfully started on task.'
    else
      render :new
    end
  end

  def destroy
    @progression.destroy
    redirect_to task_path(@task),
                notice: 'Progression was successfully destroyed.'
  end

  def finish
    if @progression.finish
      redirect_to task_path(@task),
                  notice: 'Progress was successfully finished.'
    else
      render :edit
    end
  end
end
