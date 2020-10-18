# frozen_string_literal: true

# TODO: build user#show view with assigned tasks

class UsersController < ApplicationController
  before_action :authorize_user, only: %i[index new create]
  before_action :set_user, only: %i[show edit update destroy]

  def index
    @admins = User.admins
    @reporters = User.reporters
    @reviewers = User.reviewers
    @workers = User.workers
  end

  def show
    @issues = @user.issues.order(updated_at: :desc).limit(5)
    # TODO: for reviewer+, should be created tasks
    # TODO: for worker-, should be assigned tasks
    @tasks = @user.tasks.order(updated_at: :desc).limit(5)
  end

  def new
    employee_type =
      if User::VALID_EMPLOYEE_TYPES.include?(params[:employee_type])
        params[:employee_type]
      end
    @user = User.new(employee_type: employee_type)
  end

  def edit; end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, notice: 'User was successfully created.'
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

    def set_user
      @user = authorize(User.find(params[:id]))
    end

    def user_params
      keys = @user&.persisted? ? %i[name] : %i[name email employee_type]
      params.require(:user).permit(keys)
    end

    def employee_type
      @employee_type ||= fetch_employee_type
    end

    def fetch_employee_type
      return unless params[:type] &&
                    %w[Reporter Reviewer Worker].includes?(params[:type])

      params[:type]
    end

    def authorize_user
      authorize User
    end
end
