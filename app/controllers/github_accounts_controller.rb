# frozen_string_literal: true

class GithubAccountsController < ApplicationController
  before_action :set_github_account

  def destroy
    authorize! :destroy, @github_account

    @github_account.destroy
    redirect_to edit_user_url(current_user),
                notice: 'Github Account was successfully disconnected.'
  end

  private

    def set_github_account
      @github_account = current_user.github_account
    end
end
