# TODO: allow uploading screenshots

class IssueCommentsController < ApplicationController
  load_and_authorize_resource :issue
  load_and_authorize_resource through: :issue, through_association: :comments

  def show
    redirect_to issue_path(@issue, anchor: "comment-#{@issue_comment.id}")
  end

  def new; end

  def edit; end

  def create
    if @issue_comment.save
      @issue_comment.subscribe_user
      @issue_comment.notify_subscribers

      respond_to do |format|
        format.html { redirect_to redirect_url, notice: create_notice }
        format.turbo_stream
      end
    else
      render :new
    end
  end

  def update
    if @issue_comment.update(issue_comment_params)
      respond_to do |format|
        format.html { redirect_to redirect_url, notice: update_notice }
        format.turbo_stream { redirect_to redirect_url }
      end
    else
      render :edit
    end
  end

  def destroy
    @issue_comment.destroy

    respond_to do |format|
      format.html { redirect_to @issue, notice: destroy_notice }
      format.turbo_stream
    end
  end

  private

    def issue_comment_params
      params.require(:issue_comment).permit(:body)
    end

    def redirect_url
      @redirect_url ||=
        issue_url(@issue, anchor: "comment-#{@issue_comment.id}")
    end

    def create_notice
      'Comment was successfully added.'
    end

    def update_notice
      'Comment was successfully updated.'
    end

    def destroy_notice
      'Comment was successfully removed.'
    end
end
