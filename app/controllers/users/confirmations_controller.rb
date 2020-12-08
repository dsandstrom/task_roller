# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController
    # GET /resource/confirmation/new
    # def new
    #   super
    # end

    # POST /resource/confirmation
    # def create
    #   super
    # end

    # GET /resource/confirmation?confirmation_token=abcdef
    # def show
    #   super
    # end

    protected

      # The path used after resending confirmation instructions.
      # def after_resending_confirmation_instructions_path_for(resource_name)
      #   super(resource_name)
      # end

      # The path used after confirmation.
      # https://github.com/heartcombo/devise/wiki/How-To:-Email-only-sign-up
      def after_confirmation_path_for(resource_name, resource)
        if signed_in?(resource_name)
          signed_in_root_path(resource)
        elsif resource.password?
          new_session_path(resource_name)
        else
          token = resource.send(:set_reset_password_token)
          edit_password_path(resource, reset_password_token: token)
        end
      end
  end
end
