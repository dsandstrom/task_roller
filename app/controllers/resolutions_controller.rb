# frozen_string_literal: true

class ResolutionsController < ApplicationController
  load_and_authorize_resource :issue
  load_and_authorize_resource through: :issue, except: %i[approve disapprove]
  # not sure how to tell helper to build resource
  before_action :build_and_authorize, only: %i[approve disapprove]

  def new; end

  def approve
    if @resolution.approve
      redirect_back fallback_location: @issue,
                    notice: 'Task was successfully marked resolved.'
    else
      render :new
    end
  end

  def disapprove
    if @resolution.disapprove
      redirect_back fallback_location: @issue,
                    notice: 'Task was successfully marked unresolved.'
    else
      render :new
    end
  end

  def destroy
    @resolution.destroy
    @issue.reopen(current_user) if @issue.current_resolutions.none?
    redirect_back fallback_location: @issue,
                  notice: 'Resolution was successfully destroyed.'
  end

  private

    def build_and_authorize
      @resolution = @issue.resolutions.build(user_id: current_user_id)
      authorize! :create, @resolution
    end
end
