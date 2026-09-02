class IssuePreviewsController < ApplicationController
  load_and_authorize_resource :task

  def index
    @issue = @task.issue
    @container = params[:container]

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
