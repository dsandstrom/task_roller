# frozen_string_literal: true

# TODO: allow reviewer to create/edit, but not destroy

class IssueTypesController < ApplicationController
  load_and_authorize_resource

  def index
    @task_types = TaskType.all
  end

  def new
    @issue_type.assign_attributes(color: 'default', icon: 'bulb')
  end

  def edit; end

  def create
    if @issue_type.save
      redirect_to issue_types_url,
                  notice: 'Issue type was successfully created.'
    else
      render :new
    end
  end

  def update
    if @issue_type.update(issue_type_params)
      redirect_to issue_types_url,
                  notice: 'Issue type was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @issue_type.destroy
    redirect_to issue_types_url,
                notice: 'Issue type was successfully destroyed.'
  end

  private

    def issue_type_params
      params.require(:issue_type).permit(:name, :icon, :color)
    end
end
