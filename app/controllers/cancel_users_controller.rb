# frozen_string_literal: true

class CancelUsersController < ApplicationController
  before_action :load_and_authorize_cancel

  def edit; end

  def update
    if @user.update(employee_type: nil)
      redirect(@user)
    else
      render :edit
    end
  end

  private

    def load_and_authorize_cancel
      @user = User.find(params[:id])
      authorize! :cancel, @user
    end

    def redirect(user)
      if user.id == current_user.id
        sign_out user
        redirect_to new_user_session_path,
                    notice: 'Your account was successfully cancelled.'
      else
        notice =
          "The account for #{user.name_or_email} was successfully cancelled."
        redirect_to users_path, notice: notice
      end
    end
end
