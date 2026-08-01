class TaskPreviewsController < ApplicationController
  load_and_authorize_resource :issue

  def index
    @tasks = @issue.tasks

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
