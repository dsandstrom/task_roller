# frozen_string_literal: true

class IssueReopeningsController < ApplicationController
  load_and_authorize_resource :issue, only: %i[new create]
  load_and_authorize_resource through: :issue, through_association: :reopenings,
                              only: %i[new create]
  load_and_authorize_resource only: :destroy

  def new; end

  def create
    notice = 'Issue was successfully reopened.'

    if @issue_reopening.save
      @issue.reopen
      @issue_reopening.subscribe_user
      redirect_to @issue, notice: notice
    else
      render :new
    end
  end

  def destroy
    notice = 'Issue Reopening was successfully destroyed.'
    issue = @issue_reopening.issue
    @issue_reopening.destroy
    redirect_to issue, notice: notice
  end
end
