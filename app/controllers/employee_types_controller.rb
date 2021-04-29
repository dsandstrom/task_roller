# frozen_string_literal: true

class EmployeeTypesController < ApplicationController
  load_and_authorize_resource :user
  before_action :authorize_promotion, except: :destroy
  before_action :authorize_cancellation, only: :destroy

  def new; end

  def edit; end

  def create
    if @user.update(user_params)
      notice =
        "The account type for #{@user.name_or_email} was successfully updated."
      redirect_to users_url(anchor: "user-#{@user.id}"), notice: notice
    else
      render :new
    end
  end

  def update
    if @user.update(user_params)
      notice =
        "The account type for #{@user.name_or_email} was successfully updated."
      redirect_to users_url(anchor: "user-#{@user.id}"), notice: notice
    else
      render :edit
    end
  end

  def destroy
    if @user.update(employee_type: nil)
      destroy_redirect(@user)
    else
      render :edit
    end
  end

  private

    def authorize_promotion
      authorize! :promote, @user
    end

    def authorize_cancellation
      authorize! :cancel, @user
    end

    def user_params
      params.require(:user).permit(:employee_type)
    end

    def destroy_redirect(user)
      if user.id == current_user_id
        sign_out user
        redirect_to new_user_session_path,
                    notice: 'Your account was successfully cancelled.'
      else
        notice =
          "The account for #{user.name_or_email} was successfully cancelled."
        redirect_to users_url(anchor: "user-#{@user.id}"), notice: notice
      end
    end
end
