# frozen_string_literal: true

module TestHelpers
  module Authorization
    def expect_to_be_unauthorized(response)
      expect(response).to redirect_to(:unauthorized)
    end
  end
end
