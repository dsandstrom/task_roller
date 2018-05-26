# frozen_string_literal: true

class IssueCommentsController < ApplicationController
  before_action :set_category, :set_project, :set_issue
  before_action :set_issue_comment, only: %i[edit update destroy]
  before_action :set_user_options, only: %i[new edit]

  def new
    @issue_comment = @issue.comments.build
  end

  def edit
  end

  def create
    @issue_comment = @issue.comments.build(issue_comment_params)

    if @issue_comment.save
      redirect_to category_project_issue_url(@category, @project, @issue),
                  notice: 'Issue comment was successfully created.'
    else
      set_user_options
      render :new
    end
  end

  def update
    if @issue_comment.update(issue_comment_params)
      redirect_to category_project_issue_url(@category, @project, @issue),
                  notice: 'Comment was successfully updated.'
    else
      set_user_options
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

    def set_user_options
      # TODO: only set for reviewers, otherwise always current_user
      @user_options =
        User::VALID_EMPLOYEE_TYPES.map do |type|
          [type, User.employees(type).map { |u| [u.name_and_email, u.id] }]
        end
    end

    def issue_comment_params
      params.require(:issue_comment).permit(:user_id, :body)
    end
end
