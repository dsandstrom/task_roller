# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::RegistrationsController, type: :controller do
  let(:invalid_attributes) { { name: "" } }

  describe "GET #new" do
    context "for a guest" do
      before { enable_devise_user(controller) }

      context "when not allowing registration" do
        before { allow(User).to receive(:allow_registration?) { false } }

        it "should be unauthorized" do
          get :new

          expect_to_be_unauthorized(response)
        end
      end

      context "when allowing registration" do
        before { allow(User).to receive(:allow_registration?) { true } }

        it "returns a success response" do
          get :new
          expect(response).to be_successful
        end
      end
    end
  end

  describe "GET #edit" do
    context "for an admin" do
      let(:current_user) { Fabricate(:user_admin) }

      before { sign_in(current_user) }

      context "when editing themselves" do
        before { enable_devise_user(controller, current_user) }

        it "returns a success response" do
          get :edit
          expect(response).to be_successful
        end
      end

      context "when editing another_user" do
        before { enable_devise_user(controller, Fabricate(:user_reviewer)) }

        it "returns a success response" do
          get :edit
          expect(response).to be_successful
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when editing themselves" do
          before { enable_devise_user(controller, current_user) }

          it "returns a success response" do
            get :edit
            expect(response).to be_successful
          end
        end

        context "when editing another_user" do
          before { enable_devise_user(controller, Fabricate(:user_reviewer)) }

          it "should be unauthorized" do
            get :edit
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "POST #create" do
    let(:valid_attributes) do
      { name: "User Name", email: "user-email@example.com",
        password: "123456", password_confirmation: "123456" }
    end

    before { enable_devise_user(controller) }

    context "for a guest" do
      before { enable_devise_user(controller) }

      context "when not allowing registration" do
        before { allow(User).to receive(:allow_registration?) { false } }

        it "doesn't create a new User" do
          expect do
            post :create, params: { user: valid_attributes }
          end.not_to change(User, :count)
        end

        it "should be unauthorized" do
          post :create, params: { user: valid_attributes }

          expect_to_be_unauthorized(response)
        end
      end

      context "when allowing registration" do
        before { allow(User).to receive(:allow_registration?) { true } }

        context "with valid params" do
          it "creates a new User" do
            expect do
              post :create, params: { user: valid_attributes }
            end.to change(User, :count).by(1)
          end

          it "creates a new Reporter" do
            expect do
              post :create, params: { user: valid_attributes }
            end.to change(User.reporters, :count).by(1)
          end

          it "redirects to root" do
            post :create, params: { user: valid_attributes }
            expect(response).to redirect_to(:root)
          end
        end

        context "with invalid params" do
          it "returns a success response ('new' template)" do
            post :create, params: { user: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "PUT #update" do
    let(:invalid_attributes) { { password: "" } }

    context "for an admin" do
      let(:user) { Fabricate(:user_admin) }

      let(:valid_attributes) do
        { password: "new password", password_confirmation: "new password",
          current_password: user.password }
      end

      before { sign_in(user) }

      context "when updating themselves" do
        before { enable_devise_user(controller, user) }

        context "with valid params" do
          it "updates the requested user" do
            expect do
              put :update, params: { user: valid_attributes }
              user.reload
            end.to change(user, :encrypted_password)
          end

          it "redirects to the user" do
            put :update, params: { user: valid_attributes }
            expect(response).to redirect_to(user_url(user))
          end
        end

        context "with invalid params" do
          it "returns a success response (i.e. 'edit' template)" do
            put :update, params: { user: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end

      context "when updating another user" do
        let(:another_user) { Fabricate(:user_reporter) }

        before { enable_devise_user(controller, another_user) }

        context "with valid params" do
          it "updates the requested user" do
            expect do
              put :update, params: { user: valid_attributes }
              another_user.reload
            end.to change(another_user, :encrypted_password)
          end

          it "redirects to the user" do
            put :update, params: { user: valid_attributes }
            expect(response).to redirect_to(user_url(another_user))
          end
        end

        context "with invalid params" do
          it "returns a success response (i.e. 'edit' template)" do
            put :update, params: { user: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:user) { Fabricate("user_#{employee_type}") }

        let(:valid_attributes) do
          { password: "new password", password_confirmation: "new password",
            current_password: user.password }
        end

        before { sign_in(user) }

        context "when updating themselves" do
          before { enable_devise_user(controller, user) }

          context "with valid params" do
            it "updates the requested user" do
              expect do
                put :update, params: { user: valid_attributes }
                user.reload
              end.to change(user, :encrypted_password)
            end

            it "redirects to the user" do
              put :update, params: { user: valid_attributes }
              expect(response).to redirect_to(user_url(user))
            end
          end

          context "with invalid params" do
            it "returns a success response (i.e. 'edit' template)" do
              put :update, params: { user: invalid_attributes }
              expect(response).to be_successful
            end
          end
        end

        context "when updating another user" do
          let(:another_user) { Fabricate(:user_reporter) }

          before { enable_devise_user(controller, another_user) }

          it "doesn't update the requested user" do
            expect do
              put :update, params: { user: valid_attributes }
              another_user.reload
            end.not_to change(another_user, :encrypted_password)
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:admin) { Fabricate(:user_admin) }

    context "for an admin" do
      before { sign_in(admin) }

      context "when destroying another user" do
        let(:another_user) { Fabricate(:user_reporter) }

        before { enable_devise_user(controller, another_user) }

        it "destroys the requested user" do
          expect do
            delete :destroy
          end.to change(User, :count).by(-1)
        end

        it "redirects to root" do
          delete :destroy
          expect(response).to redirect_to(:root)
        end
      end

      context "when destroying themselves" do
        before { enable_devise_user(controller, admin) }

        it "doesn't destroy the requested user" do
          expect do
            delete :destroy
          end.not_to change(User, :count)
        end

        it "should be unauthorized" do
          delete :destroy
          expect_to_be_unauthorized(response)
        end
      end

      context "when destroying a non-employee" do
        before { enable_devise_user(controller, Fabricate(:user_unemployed)) }

        it "destroys the requested user" do
          expect do
            delete :destroy
          end.to change(User, :count).by(-1)
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when another user" do
          let(:another_user) { Fabricate(:user_reporter) }

          before { enable_devise_user(controller, another_user) }

          it "doesn't destroy the requested user" do
            expect do
              delete :destroy
            end.not_to change(User, :count)
          end

          it "should be unauthorized" do
            delete :destroy
            expect_to_be_unauthorized(response)
          end
        end

        context "when themselves" do
          before { enable_devise_user(controller, current_user) }

          it "doesn't destroy the requested user" do
            expect do
              delete :destroy, params: { id: current_user.to_param }
            end.not_to change(User, :count)
          end

          it "should be unauthorized" do
            delete :destroy, params: { id: current_user.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end
end
