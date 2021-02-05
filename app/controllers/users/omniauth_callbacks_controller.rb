# frozen_string_literal: true

# https://github.com/heartcombo/devise/wiki/OmniAuth:-Overview

# TODO: Allow users to connect existing account to github
# even if registration is disallowed

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, only: :github
    before_action :verify_registration_allowed, only: :github

    def github
      redirect_to :unauthorized unless User.allow_registration?

      create_from_github
    end

    # not sure if I need to overload it
    def failure
      redirect_to :root
    end

    private

      def omniauth_payload
        @omniauth_payload ||= request.env['omniauth.auth']
      end

      def verify_registration_allowed
        return if User.allow_registration?

        redirect_to :unauthorized
      end

      def create_from_github
        @user = User.from_omniauth(omniauth_payload)

        if @user&.persisted?
          # this will throw if @user is not activated
          sign_in_and_redirect @user, event: :authentication
          if is_navigational_format?
            set_flash_message(:notice, :success, kind: 'Github')
          end
        else
          # Removing extra as it can overflow some session stores
          session['devise.github_data'] = omniauth_payload.except(:extra)
          redirect_to new_user_registration_url
        end
      end
  end
end
