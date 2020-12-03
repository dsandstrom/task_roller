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

    def enable_devise_user(view)
      without_partial_double_verification do
        allow(view).to receive(:resource) { User.new }
        allow(view).to receive(:resource_class) { User }
        allow(view).to receive(:resource_name) { :user }
        allow(view).to receive(:devise_mapping) { Devise.mappings[:user] }
      end
    end
  end
end
