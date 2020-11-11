# frozen_string_literal: true

class IssueClosuresController < ApplicationController
  load_and_authorize_resource :issue, only: %i[new create]
  load_and_authorize_resource through: :issue, through_association: :closures,
                              only: %i[new create]
  load_and_authorize_resource only: :destroy

  def new; end

  def create
    notice = 'Issue was successfully closed.'

    if @issue_closure.save
      @issue.close
      @issue_closure.subscribe_user
      redirect_to @issue, notice: notice
    else
      render :new
    end
  end

  def destroy
    notice = 'Issue Closure was successfully destroyed.'
    issue = @issue_closure.issue
    @issue_closure.destroy
    redirect_to issue, notice: notice
  end
end
