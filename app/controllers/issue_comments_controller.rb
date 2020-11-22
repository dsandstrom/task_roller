# frozen_string_literal: true

class IssueCommentsController < ApplicationController
  load_and_authorize_resource :issue
  load_and_authorize_resource through: :issue, through_association: :comments

  def new; end

  def edit; end

  def create
    if @issue_comment.save
      @issue_comment.subscribe_user
      redirect_to issue_url(@issue, anchor: "comment-#{@issue_comment.id}")
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

    def issue_comment_params
      params.require(:issue_comment).permit(:body)
    end
end
