# frozen_string_literal: true

class ResolutionsController < ApplicationController
  load_and_authorize_resource :issue
  load_and_authorize_resource through: :issue, except: %i[approve disapprove]
  before_action :build_and_authorize, only: %i[approve disapprove]
  before_action :set_category_and_project, except: [:index]

  def index; end

  def new; end

  def approve
    if @resolution.approve
      redirect_to @issue, notice: 'Task was successfully marked resolved.'
    else
      render :new
    end
  end

  def disapprove
    if @resolution.disapprove
      redirect_to @issue, notice: 'Task was successfully marked unresolved.'
    else
      render :new
    end
  end

  def destroy
    @resolution.destroy
    redirect_to @issue, notice: 'Resolution was successfully destroyed.'
  end

  private

    def build_and_authorize
      @resolution = @issue.resolutions.build(user_id: current_user.id)
      authorize! :create, @resolution
    end

    def set_category_and_project
      @project = @issue.project
      @category = @issue.category
    end
end
