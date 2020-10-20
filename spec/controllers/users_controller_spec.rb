# frozen_string_literal: true

require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let(:invalid_attributes) { { name: "" } }

  describe "GET #index" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type.downcase}")) }

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
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type.downcase}")) }

        it "returns a success response" do
          user = Fabricate(:user)
          get :show, params: { id: user.to_param }
          expect(response).to be_successful
        end
      end
    end
  end

  describe "GET #new" do
    context "for an admin" do
      before { login(Fabricate(:user_admin)) }

      it "returns a success response" do
        get :new
        expect(response).to be_successful
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          get :new, params: {}
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "GET #edit" do
    context "for an admin" do
      before { login(Fabricate(:user_admin)) }

      it "returns a success response" do
        user = Fabricate(:user)
        get :edit, params: { id: user.to_param }
        expect(response).to be_successful
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "when editing another user" do
          it "should be unauthorized" do
            user = Fabricate(:user)
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
      before { login(Fabricate(:user_admin)) }

      context "with valid params" do
        it "creates a new User" do
          expect do
            post :create, params: { user: valid_attributes }
          end.to change(User, :count).by(1)
        end

        it "redirects to the created user" do
          post :create, params: { user: valid_attributes }
          expect(response).to redirect_to(User.last)
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
        before { login(Fabricate("user_#{employee_type}")) }

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
      before { login(Fabricate(:user_admin)) }

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

        before { login(current_user) }

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
      before { login(admin) }

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
    end
  end
end
