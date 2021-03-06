# frozen_string_literal: true

class IssueConnectionsController < ApplicationController
  before_action :load_and_authorize, only: %i[new create]
  authorize_resource only: %i[new create]
  load_and_authorize_resource except: %i[new create]

  def new; end

  def create
    notice = 'Issue was successfully closed and marked as a duplicate.'

    if @issue_connection.save
      @issue_connection.source.close(current_user)
      @issue_connection.subscribe_user
      redirect_to @issue_connection.source, notice: notice
    else
      render :new
    end
  end

  def destroy
    notice = 'Issue was successfully reopened.'
    issue = @issue_connection.source
    authorize! :read, issue

    if @issue_connection.destroy
      issue.reopen(current_user)
      issue.reopenings.create(user_id: current_user_id)
    end
    redirect_to issue, notice: notice
  end

  private

    def load_and_authorize
      if params[:issue_connection]
        target_id = issue_connection_params[:target_id]
      end
      @issue_connection =
        IssueConnection.new(source_id: params[:source_id], target_id: target_id,
                            user_id: current_user_id)
      authorize! :read, @issue_connection.source
    end

    def issue_connection_params
      params.require(:issue_connection).permit(:target_id)
    end
end
