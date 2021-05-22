# frozen_string_literal: true

class UsersController < ApplicationController
  load_and_authorize_resource
  load_resource :active_assignments, through: :user, singleton: true,
                                     only: :show
  load_resource :open_tasks, through: :user, singleton: true, only: :show
  load_resource :unresolved_issues, through: :user, singleton: true, only: :show

  def index
    @admins = @users.admins
    @reporters = @users.reporters
    @reviewers = @users.reviewers
    @workers = @users.workers
    @unemployed = @users.unemployed
  end

  # TODO: add with_notifications
  def show
    @unresolved_issues =
      @unresolved_issues.all_visible.accessible_by(current_ability)
    @open_tasks = @open_tasks.all_visible.accessible_by(current_ability)
    @active_assignments =
      @active_assignments.all_visible.accessible_by(current_ability)
  end

  def new; end

  def edit; end

  def create
    if @user.save
      redirect_to users_url, notice: 'User was successfully created.'
    else
      render :new, type: employee_type
    end
  end

  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
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
end
