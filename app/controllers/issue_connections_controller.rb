# frozen_string_literal: true

class IssueConnectionsController < ApplicationController
  before_action :build_issue_connection, only: %i[new create]
  before_action :set_issue_connection, only: :destroy

  def new; end

  def create
    notice = 'Issue was successfully closed and marked as a duplicate.'

    if @issue_connection.save
      @issue_connection.source.close
      @issue_connection.subscribe_user
      redirect_to @issue_connection.source, notice: notice
    else
      render :new
    end
  end

  # TODO: add active to connections - disable instead of destroy
  def destroy
    notice = 'Issue was successfully reopened.'
    issue = @issue_connection.source
    @issue_connection.destroy
    issue.reopen
    issue.reopenings.create(user_id: current_user.id)
    redirect_to issue, notice: notice
  end

  private

    def build_issue_connection
      if params[:issue_connection]
        target_id = issue_connection_params[:target_id]
      end
      @issue_connection =
        IssueConnection.new(source_id: params[:source_id], target_id: target_id,
                            user_id: current_user.id)
      authorize! :create, @issue_connection
    end

    def set_issue_connection
      @issue_connection = IssueConnection.find(params[:id])
      authorize! :destroy, @issue_connection
    end

    def issue_connection_params
      params.require(:issue_connection).permit(:target_id)
    end
end
