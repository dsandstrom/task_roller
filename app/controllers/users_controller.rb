# frozen_string_literal: true

class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    @admins = @users.admins
    @reporters = @users.reporters
    @reviewers = @users.reviewers
    @workers = @users.workers
  end

  # TODO: show tasks from reviews by user
  # TODO: for reviewer+, show tasks ready for review
  def show; end

  def new; end

  def edit; end

  def create
    if @user.save
      redirect_to users_url, notice: 'User was successfully created.'
    else
      render :new, type: employee_type
    end
  end

  # TODO: allow admin to change employee_type
  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def cancel
    if @user.update(employee_type: nil)
      cancel_redirect(@user)
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private

    def user_params
      keys = @user&.persisted? ? %i[name] : %i[name email employee_type]
      params.require(:user).permit(keys)
    end

    def employee_type
      @employee_type ||= build_employee_type
    end

    def build_employee_type
      return unless params[:type] &&
                    %w[Reporter Reviewer Worker].includes?(params[:type])

      params[:type]
    end

    def cancel_redirect(user)
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
