# frozen_string_literal: true

# TODO: create subscription on create

class IssueCommentsController < ApplicationController
  before_action :authorize_issue_comment, only: %i[index new create destroy]
  before_action :set_issue, only: %i[new create]
  before_action :set_issue_comment, only: %i[edit update destroy]

  def new
    @issue_comment = @issue.comments.build
  end

  def edit
  end

  def create
    @issue_comment = @issue.comments.build(issue_comment_params)
    @issue_comment.user_id = current_user.id

    if @issue_comment.save
      redirect_to issue_url(@issue, anchor: "comment-#{@issue_comment.id}"),
                  notice: 'Comment was successfully created.'
    else
      render :new
    end
  end

  def update
    if @issue_comment.update(issue_comment_params)
      redirect_to issue_url(@issue, anchor: "comment-#{@issue_comment.id}"),
                  notice: 'Comment was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @issue_comment.destroy
    redirect_to issue_url(@issue),
                notice: 'Comment was successfully destroyed.'
  end

  private

    def authorize_issue_comment
      authorize IssueComment
    end

    def set_issue
      @issue = Issue.find(params[:issue_id])
    end

    def set_issue_comment
      @issue_comment = authorize(IssueComment.find(params[:id]))
      @issue = @issue_comment.issue
    end

    def issue_comment_params
      params.require(:issue_comment).permit(:body)
    end
end
