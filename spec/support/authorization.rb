# frozen_string_literal: true

module TestHelpers
  module Authorization
    def expect_to_be_unauthorized(response)
      expect(response).to redirect_to(:unauthorized)
    end

    def expect_to_be_forbidden(response)
      expect(response).to have_http_status(:forbidden)
    end

    def enable_devise_user(controller, user = nil)
      without_partial_double_verification do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        allow(controller).to receive(:resource) { user } if user
      end
    end
  end
end
