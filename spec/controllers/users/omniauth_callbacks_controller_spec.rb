# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  describe "POST #github" do
    let(:example_user) { Fabricate.build(:user_reviewer) }

    let(:user_env) do
      OmniAuth::AuthHash.new(email: example_user.email, name: example_user.name,
                             nickname: "username")
    end

    let(:auth_env) do
      OmniAuth::AuthHash.new(uid: 1234, info: user_env,
                             extra: OmniAuth::AuthHash.new,
                             all_emails: OmniAuth::AuthHash.new,
                             urls: OmniAuth::AuthHash.new)
    end

    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @request.env["omniauth.auth"] = auth_env
    end

    # TODO: when user matches email, but nil/different gitub_id
    context "when registration is allowed" do
      before { allow(User).to receive(:allow_registration?) { true } }

      context "for a guest" do
        context "when valid environment" do
          context "that doesn't match an existing user" do
            it "creates a new user" do
              expect do
                get :github
              end.to change(User, :count).by(1)
            end

            it "redirects to root" do
              get :github
              expect(response).to redirect_to(:root)
            end
          end

          context "that email and github_id match a confirmed user" do
            before do
              example_user.github_id = 1234
              example_user.save
            end

            it "doesn't create a new user" do
              expect do
                get :github
              end.not_to change(User, :count)
            end

            it "redirects to root" do
              get :github
              expect(response).to redirect_to(:root)
            end
          end

          context "that email and github_id match an confirmed user" do
            before do
              example_user.github_id = 1234
              example_user.confirmed_at = nil
              example_user.save
            end

            it "doesn't create a new user" do
              expect do
                get :github
              end.not_to change(User, :count)
            end

            it "redirects to sign_in" do
              get :github
              expect(response).to redirect_to(:new_user_session)
            end
          end
        end

        context "when invalid env" do
          let(:user_env) do
            OmniAuth::AuthHash.new(email: nil, name: example_user.name,
                                   nickname: "username")
          end

          it "doesn't create a new user" do
            expect do
              get :github
            end.not_to change(User, :count)
          end

          it "copies payload to session" do
            get :github
            expect(session["devise.github_data"]).not_to be_nil
            expect(session["devise.github_data"]["extra"]).to be_nil
          end

          it "redirects to sign_in" do
            get :github
            expect(response).to redirect_to(:new_user_session)
          end
        end
      end
    end

    context "when registration is not allowed" do
      before { allow(User).to receive(:allow_registration?) { false } }

      context "for a guest" do
        before do
          allow(auth_env).to receive(:uid) { 1234 }
          allow(auth_env).to receive(:info) { user_env }
        end

        it "doesn't create a new user" do
          expect do
            get :github
          end.not_to change(User, :count)
        end

        it "redirects to unauthorized" do
          get :github
          expect_to_be_unauthorized(response)
        end
      end

      context "for a reporter" do
        context "when valid environment" do
          before do
            allow(auth_env).to receive(:uid) { 1234 }
            allow(auth_env).to receive(:info) { user_env }
          end

          context "that doesn't match an existing user" do
            it "doesn't create a new user" do
              expect do
                get :github
              end.not_to change(User, :count)
            end

            it "redirects to unauthorized" do
              get :github
              expect_to_be_unauthorized(response)
            end
          end

          context "that email and github_id match an existing user" do
            before do
              example_user.github_id = 1234
              example_user.save
            end

            it "doesn't create a new user" do
              expect do
                get :github
              end.not_to change(User, :count)
            end

            it "redirects to unauthorized" do
              get :github
              expect_to_be_unauthorized(response)
            end
          end

          context "when email matches an existing user" do
            before { example_user.save }

            it "doesn't create a new user" do
              expect do
                get :github
              end.not_to change(User, :count)
            end

            it "redirects to unauthorized" do
              get :github
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "when invalid env" do
          before do
            user_env.email = nil
            allow(auth_env).to receive(:uid) { 1234 }
            allow(auth_env).to receive(:info) { user_env }
          end

          it "doesn't create a new user" do
            expect do
              get :github
            end.not_to change(User, :count)
          end

          it "redirects to unauthorized" do
            get :github
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end
end
