# frozen_string_literal: true

# make `policy` available in view specs
# https://github.com/varvet/pundit/issues/339#issuecomment-449454629

module TestHelpers
  module Pundit
    def enable_pundit(view, user)
      without_partial_double_verification do
        allow(view).to receive(:policy) do |record|
          ::Pundit.policy(user, record)
        end
      end
    end
  end
end
