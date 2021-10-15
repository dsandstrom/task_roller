# frozen_string_literal: true

# https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, only: :github

    def github
      if current_user
        update_current_user
      elsif User.allow_registration?
        create_new_user
      else
        redirect_to :unauthorized
      end
    end

    def failure
      redirect_to :new_user_session, alert: sign_in_failure_message
    end

    private

      def omniauth_payload
        @omniauth_payload ||= request.env['omniauth.auth']
      end

      def sign_in_failure_message
        @sign_in_failure_message ||= 'Unable to sign in with GitHub'
      end

      def log_errors_and_redirect
        # Removing extra as it can overflow some session stores
        %i[extra all_emails urls].each { |key| omniauth_payload.delete(key) }
        session['devise.github_data'] = omniauth_payload
        logger.info 'Unable to create user from GitHub:'
        logger.info @user.errors.messages.inspect
        redirect_to new_user_session_url, alert: sign_in_failure_message
      end

      def update_current_user
        if current_user.add_omniauth(omniauth_payload)
          redirect_to edit_user_url(current_user)
        else
          redirect_to :unauthorized
        end
      end

      def create_new_user
        @user = User.from_omniauth(omniauth_payload)

        if @user&.persisted?
          # this will throw if @user is not activated
          sign_in_and_redirect @user, event: :authentication
          if is_navigational_format?
            set_flash_message(:notice, :success, kind: 'Github')
          end
        else
          log_errors_and_redirect
        end
      end
  end
end
