# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::ConfirmationsController, type: :controller do
  describe "GET #show" do
    context "for an unconfirmed reporter" do
      context "that just signed up" do
        let(:user) do
          Fabricate(:user_reporter, confirmed_at: nil,
                                    password: "pass123",
                                    password_confirmation: "pass123",
                                    confirmation_token: "token")
        end

        before do
          enable_devise_user(controller)
          user
        end

        it "confirms the user" do
          expect do
            get :show, params: { confirmation_token: "token" }
            user.reload
          end.to change(user, :confirmed_at).from(nil)
        end

        it "doesn't set reset_password_token" do
          expect do
            get :show, params: { confirmation_token: "token" }
            user.reload
          end.not_to change(user, :reset_password_token)
        end

        it "redirects to login" do
          get :show, params: { confirmation_token: "token" }
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context "that was invited without password" do
        let(:user) do
          Fabricate(:user_reporter, confirmed_at: nil,
                                    password: nil, password_confirmation: nil,
                                    confirmation_token: "token")
        end

        before do
          enable_devise_user(controller)
          user
        end

        it "confirms the user" do
          expect do
            get :show, params: { confirmation_token: "token" }
            user.reload
          end.to change(user, :confirmed_at).from(nil)
        end

        it "sets reset_password_token" do
          expect do
            get :show, params: { confirmation_token: "token" }
            user.reload
          end.to change(user, :reset_password_token).from(nil)
        end

        it "redirects to password edit" do
          expect_any_instance_of(User)
            .to receive(:set_reset_password_token) { "passtoken" }
          get :show, params: { confirmation_token: "token" }
          url = "#{edit_user_password_url}?reset_password_token=passtoken"
          expect(response).to redirect_to(url)
        end
      end

      context "that is already signed in" do
        let(:user) do
          Fabricate(:user_reporter, confirmed_at: nil,
                                    password: "pass123",
                                    password_confirmation: "pass123",
                                    confirmation_token: "token")
        end

        before do
          sign_in(user)
          enable_devise_user(controller, user)
        end

        it "confirms the user" do
          expect do
            get :show, params: { confirmation_token: "token" }
            user.reload
          end.to change(user, :confirmed_at).from(nil)
        end

        it "doesn't set reset_password_token" do
          expect do
            get :show, params: { confirmation_token: "token" }
            user.reload
          end.not_to change(user, :reset_password_token)
        end

        it "redirects to root" do
          get :show, params: { confirmation_token: "token" }
          expect(response).to redirect_to(:root)
        end
      end
    end
  end
end
