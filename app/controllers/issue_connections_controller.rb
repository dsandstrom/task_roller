# frozen_string_literal: true

class IssueConnectionsController < ApplicationController
  before_action :authorize_issue_connection
  before_action :build_issue_connection, only: :create
  before_action :set_issue_connection, only: :destroy

  def new
    @issue_connection = IssueConnection.new(source_id: params[:source_id])
  end

  def create
    notice = 'Issue was successfully closed and marked as a duplicate.'

    if @issue_connection.save
      @issue_connection.source.close
      path = category_project_issue_path(@issue_connection.source.category,
                                         @issue_connection.source.project,
                                         @issue_connection.source)
      redirect_to path, notice: notice
    else
      render :new
    end
  end

  def destroy
    notice = 'Issue was successfully reopened.'
    path = category_project_issue_path(@issue_connection.source.category,
                                       @issue_connection.source.project,
                                       @issue_connection.source)
    @issue_connection.destroy
    @issue_connection.source.open
    redirect_to path, notice: notice
  end

  private

    def authorize_issue_connection
      authorize IssueConnection
    end

    def build_issue_connection
      @issue_connection =
        IssueConnection.new(source_id: params[:source_id],
                            target_id: issue_connection_params[:target_id])
    end

    def set_issue_connection
      @issue_connection = IssueConnection.find(params[:id])
      authorize @issue_connection
    end

    def issue_connection_params
      params.require(:issue_connection).permit(:target_id)
    end
end
