# frozen_string_literal: true

# TODO: allow users without passwords (github), to add one

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: :create
    # before_action :configure_account_update_params, only: [:update]

    # GET /resource/sign_up
    # def new
    #   super
    # end

    # POST /resource
    # def create
    #   super
    # end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    protected

      # If you have extra params to permit, append them to the sanitizer.
      def configure_sign_up_params
        devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
      end

      # Build a devise resource passing in the session. Useful to move
      # temporary session data to the newly created user.
      def build_resource(hash = {})
        super
        resource.employee_type ||= 'Reporter'
        authorize! params[:action].to_sym, resource
      end

      # Authenticates the current scope and gets the current resource from the
      # session.
      # runs on edit, update, destroy
      def authenticate_scope!
        super
        authorize! params[:action].to_sym, resource
      end

      def after_update_path_for(resource)
        if sign_in_after_change_password?
          user_path(resource)
        else
          new_session_path(resource_name)
        end
      end

    # If you have extra params to permit, append them to the sanitizer.
    # def configure_account_update_params
    #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
    # end

    # The path used after sign up.
    # def after_sign_up_path_for(resource)
    #   super(resource)
    # end

    # The path used after sign up for inactive accounts.
    # def after_inactive_sign_up_path_for(resource)
    #   super(resource)
    # end
  end
end
