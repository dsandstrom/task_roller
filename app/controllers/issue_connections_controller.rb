# frozen_string_literal: true

class IssueConnectionsController < ApplicationController
  before_action :build_issue_connection, only: :create
  before_action :set_issue_connection, only: :destroy

  def new
  end

  def create
    if @issue_connection.save
      path = category_project_issue_path(@issue_connection.source.category,
                                         @issue_connection.source.project,
                                         @issue_connection.source)
      redirect_to path, notice: 'Issue connection was successfully created.'
    else
      render :new
    end
  end

  def destroy
    path = category_project_issue_path(@issue_connection.source.category,
                                       @issue_connection.source.project,
                                       @issue_connection.source)
    @issue_connection.destroy
    redirect_to path, notice: 'Issue connection was successfully destroyed.'
  end

  private

    def build_issue_connection
      @issue_connection = IssueConnection.new(source_id: params[:source_id],
                                              target_id: params[:target_id])
    end

    def set_issue_connection
      @issue_connection = IssueConnection.find(params[:id])
    end
end
