# frozen_string_literal: true

class IssueTypesController < ApplicationController
  before_action :set_issue_type, only: %i[edit update destroy]

  def new
    @issue_type = IssueType.new(color: 'default', icon: 'bulb')
  end

  def edit; end

  def create
    @issue_type = IssueType.new(issue_type_params)

    if @issue_type.save
      redirect_to roller_types_url,
                  notice: 'Issue type was successfully created.'
    else
      render :new
    end
  end

  def update
    if @issue_type.update(issue_type_params)
      redirect_to roller_types_url,
                  notice: 'Issue type was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @issue_type.destroy
    redirect_to roller_types_url,
                notice: 'Issue type was successfully destroyed.'
  end

  private

    def issue_type_params
      params.require(:issue_type).permit(:name, :icon, :color)
    end
end
