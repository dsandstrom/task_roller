# frozen_string_literal: true

class PromoteUsersController < ApplicationController
  before_action :load_and_authorize_promotion

  def edit; end

  def update
    if @user.update(user_params)
      notice =
        "The account type for #{@user.name_or_email} was successfully updated."
      redirect_to users_url(anchor: "user-#{@user.id}"), notice: notice
    else
      render :edit
    end
  end

  private

    def load_and_authorize_promotion
      @user = User.find(params[:id])
      authorize! :promote, @user
    end

    def user_params
      params.require(:user).permit(:employee_type)
    end
end
