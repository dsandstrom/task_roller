# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let(:invalid_attributes) { { name: "", employee_type: "Reporter" } }

  describe "GET #index" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type.downcase}")) }

        context "when no users" do
          it "returns a success response" do
            get :index
            expect(response).to be_successful
          end
        end

        context "when users" do
          it "returns a success response" do
            Fabricate(:user_reporter)
            Fabricate(:user_reviewer)
            Fabricate(:user_worker)
            get :index
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "GET #show" do
    context "for an admin" do
      let(:current_user) { Fabricate(:user_admin) }

      before { sign_in(current_user) }

      context "when user has an employee_type" do
        it "returns a success response" do
          user = Fabricate(:user)
          get :show, params: { id: user.to_param }
          expect(response).to be_successful
        end
      end

      context "when user doesn't have an employee_type" do
        it "returns a success response" do
          user = Fabricate(:user_unemployed)
          get :show, params: { id: user.to_param }
          expect(response).to be_successful
        end
      end

      context "when themself" do
        it "returns a success response" do
          get :show, params: { id: current_user.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when user has an employee_type" do
          it "returns a success response" do
            user = Fabricate(:user)
            get :show, params: { id: user.to_param }
            expect(response).to be_successful
          end
        end

        context "when themself" do
          it "returns a success response" do
            get :show, params: { id: current_user.to_param }
            expect(response).to be_successful
          end
        end

        context "when user doesn't have an employee_type" do
          it "should be unauthorized" do
            user = Fabricate(:user_unemployed)
            get :show, params: { id: user.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "GET #new" do
    context "for an admin" do
      before { sign_in(Fabricate(:user_admin)) }

      context "when valid employee_type" do
        it "returns a success response" do
          get :new, params: { user: { employee_type: "Reporter" } }
          expect(response).to be_successful
        end
      end

      context "when invalid employee_type" do
        it "returns a success response" do
          get :new, params: { user: { employee_type: "Invalid" } }
          expect(response).to be_successful
        end
      end

      context "when no employee_type" do
        it "should be unauthorized" do
          get :new, params: {}
          expect_to_be_unauthorized(response)
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          get :new, params: { user: { employee_type: "Reporter" } }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "GET #edit" do
    context "for an admin" do
      before { sign_in(Fabricate(:user_admin)) }

      context "when user has an employee_type" do
        it "returns a success response" do
          user = Fabricate(:user)
          get :edit, params: { id: user.to_param }
          expect(response).to be_successful
        end
      end

      context "when user doesn't have an employee_type" do
        it "returns a success response" do
          user = Fabricate(:user_unemployed)
          get :edit, params: { id: user.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when editing another user" do
          it "should be unauthorized" do
            user = Fabricate(:user)
            get :edit, params: { id: user.to_param }
            expect_to_be_unauthorized(response)
          end
        end

        context "when editing non employee" do
          it "should be unauthorized" do
            user = Fabricate(:user_unemployed)
            get :edit, params: { id: user.to_param }
            expect_to_be_unauthorized(response)
          end
        end

        context "when editing themselves" do
          it "returns a success response" do
            get :edit, params: { id: current_user.to_param }
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "POST #create" do
    let(:valid_attributes) do
      { name: "User Name", email: "user-email@example.com",
        employee_type: "Worker" }
    end

    context "for an admin" do
      before { sign_in(Fabricate(:user_admin)) }

      context "with valid params" do
        it "creates a new User" do
          expect do
            post :create, params: { user: valid_attributes }
          end.to change(User, :count).by(1)
        end

        it "redirects to the created user" do
          post :create, params: { user: valid_attributes }
          expect(response).to redirect_to(users_url)
        end
      end

      context "with invalid params" do
        it "returns a success response (i.e. to display the 'new' template)" do
          post :create, params: { user: invalid_attributes }
          expect(response).to be_successful
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          post :create, params: { user: valid_attributes }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "PUT #update" do
    let(:valid_attributes) { { name: "New Name" } }
    let(:email_attributes) do
      { name: "New Name", email: "new-email@example.com" }
    end

    context "for an admin" do
      before { sign_in(Fabricate(:user_admin)) }

      context "with valid params" do
        it "updates the requested user" do
          user = Fabricate(:user)
          expect do
            put :update, params: { id: user.to_param, user: valid_attributes }
            user.reload
          end.to change(user, :name).to("New Name")
        end

        it "redirects to the user" do
          user = Fabricate(:user)
          put :update, params: { id: user.to_param, user: valid_attributes }
          expect(response).to redirect_to(user)
        end
      end

      context "with invalid params" do
        it "returns a success response (i.e. to display the 'edit' template)" do
          user = Fabricate(:user)
          put :update, params: { id: user.to_param, user: invalid_attributes }
          expect(response).to be_successful
        end
      end

      context "with email hash params" do
        it "doesn't updates the requested user's email" do
          user = Fabricate(:user)
          expect do
            put :update, params: { id: user.to_param, user: email_attributes }
            user.reload
          end.not_to change(user, :email)
        end

        it "redirects to the user" do
          user = Fabricate(:user)
          put :update, params: { id: user.to_param, user: email_attributes }
          expect(response).to redirect_to(user)
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when editing another user" do
          it "should be unauthorized" do
            user = Fabricate(:user)
            put :update, params: { id: user.to_param, user: valid_attributes }
            expect_to_be_unauthorized(response)
          end
        end

        context "when updating themselves" do
          context "with valid params" do
            it "updates the requested user" do
              expect do
                put :update, params: { id: current_user.to_param,
                                       user: valid_attributes }
                current_user.reload
              end.to change(current_user, :name).to("New Name")
            end

            it "redirects to the user" do
              put :update, params: { id: current_user.to_param,
                                     user: valid_attributes }
              expect(response).to redirect_to(current_user)
            end
          end

          context "with invalid params" do
            it "returns a success response (edit template)" do
              put :update, params: { id: current_user.to_param,
                                     user: invalid_attributes }
              expect(response).to be_successful
            end
          end

          context "with email hash params" do
            it "doesn't updates the requested user's email" do
              expect do
                put :update, params: { id: current_user.to_param,
                                       user: email_attributes }
                current_user.reload
              end.not_to change(current_user, :email)
            end

            it "redirects to the user" do
              put :update, params: { id: current_user.to_param,
                                     user: email_attributes }
              expect(response).to redirect_to(current_user)
            end
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
        it "destroys the requested user" do
          user = Fabricate(:user)
          expect do
            delete :destroy, params: { id: user.to_param }
          end.to change(User, :count).by(-1)
        end

        it "redirects to the users list" do
          user = Fabricate(:user)
          delete :destroy, params: { id: user.to_param }
          expect(response).to redirect_to(users_url)
        end
      end

      context "when destroying themselves" do
        it "doesn't destroy the requested user" do
          expect do
            delete :destroy, params: { id: admin.to_param }
          end.not_to change(User, :count)
        end

        it "should be unauthorized" do
          delete :destroy, params: { id: admin.to_param }
          expect_to_be_unauthorized(response)
        end
      end

      context "when destroying a non-employee" do
        it "destroys the requested user" do
          user = Fabricate(:user_unemployed)
          expect do
            delete :destroy, params: { id: user.to_param }
          end.to change(User, :count).by(-1)
        end

        it "redirects to the users list" do
          user = Fabricate(:user_unemployed)
          delete :destroy, params: { id: user.to_param }
          expect(response).to redirect_to(users_url)
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when another user" do
          it "doesn't destroy the requested user" do
            user = Fabricate(:user)
            expect do
              delete :destroy, params: { id: user.to_param }
            end.not_to change(User, :count)
          end

          it "should be unauthorized" do
            user = Fabricate(:user)
            delete :destroy, params: { id: user.to_param }
            expect_to_be_unauthorized(response)
          end
        end

        context "when a non-employee" do
          it "doesn't destroy the requested user" do
            user = Fabricate(:user_unemployed)
            expect do
              delete :destroy, params: { id: user.to_param }
            end.not_to change(User, :count)
          end

          it "should be unauthorized" do
            user = Fabricate(:user_unemployed)
            delete :destroy, params: { id: user.to_param }
            expect_to_be_unauthorized(response)
          end
        end

        context "when themself" do
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

  describe "PATCH #cancel" do
    context "for an admin" do
      let(:current_user) { Fabricate(:user_admin) }

      before { sign_in(current_user) }

      context "when cancelling another user" do
        it "updates the requested user" do
          user = Fabricate(:user)
          expect do
            put :cancel, params: { id: user.to_param }
            user.reload
          end.to change(user, :employee_type).to(nil)
        end

        it "doesn't sign out the current_user" do
          user = Fabricate(:user)
          expect do
            put :cancel, params: { id: user.to_param }
            user.reload
          end.not_to change(controller, :current_user)
        end

        it "redirects to users" do
          user = Fabricate(:user)
          put :cancel, params: { id: user.to_param }
          expect(response).to redirect_to(:users)
        end
      end

      context "when cancelling themselves" do
        it "doesn't update the requested user" do
          expect do
            put :cancel, params: { id: current_user.to_param }
            current_user.reload
          end.not_to change(current_user, :employee_type)
        end

        it "should be unauthorized" do
          put :cancel, params: { id: current_user.to_param }
          expect_to_be_unauthorized(response)
        end
      end

      context "when cancelling an invalid user" do
        let(:user) { Fabricate(:user) }

        before { user.update_attribute :name, nil }

        it "doesn't update the requested user" do
          expect do
            put :cancel, params: { id: user.to_param }
            user.reload
          end.not_to change(user, :employee_type)
        end

        it "doesn't sign out the current_user" do
          expect do
            put :cancel, params: { id: user.to_param }
            user.reload
          end.not_to change(controller, :current_user)
        end

        it "renders edit" do
          user = Fabricate(:user)
          user.update_attribute :name, nil
          put :cancel, params: { id: user.to_param }
          expect(response).to be_successful
        end
      end

      context "when cancelling an non employee" do
        let(:user) { Fabricate(:user_unemployed) }

        it "doesn't update the requested user" do
          expect do
            put :cancel, params: { id: user.to_param }
            user.reload
          end.not_to change(user, :employee_type).from(nil)
        end

        it "doesn't sign out the current_user" do
          expect do
            put :cancel, params: { id: user.to_param }
            user.reload
          end.not_to change(controller, :current_user)
        end

        it "redirects to users" do
          put :cancel, params: { id: user.to_param }
          expect(response).to redirect_to(:users)
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when cancelling another user" do
          it "doesn't update the requested user" do
            user = Fabricate(:user)
            expect do
              put :cancel, params: { id: user.to_param }
              user.reload
            end.not_to change(user, :employee_type)
          end

          it "should be unauthorized" do
            user = Fabricate(:user)
            put :cancel, params: { id: user.to_param }
            expect_to_be_unauthorized(response)
          end
        end

        context "when cancelling themselves" do
          it "updates the requested user" do
            expect do
              put :cancel, params: { id: current_user.to_param }
              current_user.reload
            end.to change(current_user, :employee_type).to(nil)
          end

          it "signs out the user" do
            expect do
              put :cancel, params: { id: current_user.to_param }
              current_user.reload
            end.to change(controller, :current_user).to(nil)
          end

          it "redirects to sign in" do
            put :cancel, params: { id: current_user.to_param }
            expect(response).to redirect_to(new_user_session_path)
          end
        end
      end
    end
  end
end
