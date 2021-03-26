# frozen_string_literal: true

# TODO: comment form validation

class IssueCommentsController < ApplicationController
  load_and_authorize_resource :issue
  load_and_authorize_resource through: :issue, through_association: :comments

  def new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    respond_to do |format|
      format.html do
        redirect_to issue_path(@issue, anchor: "comment-#{@issue_comment.id}")
      end
      format.js
    end
  end

  def create
    if @issue_comment.save
      @issue_comment.subscribe_user
      @issue_comment.notify_subscribers
      create_success
    else
      create_failure
    end
  end

  def update
    if @issue_comment.update(issue_comment_params)
      update_success
    else
      update_failure
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

    def redirect_url
      @redirect_url ||=
        issue_url(@issue, anchor: "comment-#{@issue_comment.id}")
    end

    def create_success
      respond_to do |format|
        format.html { redirect_to redirect_url }
        format.js { render :show }
      end
    end

    def create_failure
      respond_to do |format|
        format.html { render :new }
        format.js { render :new }
      end
    end

    def update_success
      respond_to do |format|
        format.html do
          redirect_to redirect_url, notice: 'Comment was successfully updated.'
        end
        format.js { render :show }
      end
    end

    def update_failure
      respond_to do |format|
        format.html { render :edit }
        format.js do
          @issue_comment.reload
          render :show
        end
      end
    end
end
