# frozen_string_literal: true

module TestHelpers
  module Authentication
    def enable_can(view, user)
      without_partial_double_verification do
        allow(view).to receive(:can?) do |action, record|
          ability = Ability.new(user)
          ability.can?(action, record)
        end
        allow(view).to receive(:current_user) { user }
      end
    end
  end
end
