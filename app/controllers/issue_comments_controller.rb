# frozen_string_literal: true

class IssueCommentsController < ApplicationController
  before_action :set_category, :set_project, :set_issue
  before_action :set_issue_comment, only: %i[edit update destroy]

  def new
    @issue_comment = @issue.comments.build
  end

  def edit
  end

  def create
    @issue_comment = @issue.comments.build(issue_comment_params)

    if @issue_comment.save
      redirect_to redirect_url, notice: 'Comment was successfully created.'
    else
      render :new
    end
  end

  def update
    if @issue_comment.update(issue_comment_params)
      redirect_to redirect_url, notice: 'Comment was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @issue_comment.destroy
    redirect_to category_project_issue_url(@category, @project, @issue),
                notice: 'Comment was successfully destroyed.'
  end

  private

    def set_issue
      @issue = Issue.find(params[:issue_id])
    end

    def set_issue_comment
      @issue_comment = @issue.comments.find(params[:id])
    end

    def redirect_url
      @redirect_url ||=
        category_project_issue_url(@category, @project, @issue,
                                   anchor: "comment-#{@issue_comment.id}")
    end

    # TODO: only allow body
    def issue_comment_params
      params.require(:issue_comment).permit(:user_id, :body)
    end
end
