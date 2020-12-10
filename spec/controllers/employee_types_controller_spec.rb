# frozen_string_literal: true

require "rails_helper"

RSpec.describe EmployeeTypesController, type: :controller do
  let(:valid_params) { { employee_type: "Worker" } }
  let(:invalid_params) { { employee_type: "" } }

  describe "GET #new" do
    context "for an admin" do
      let(:current_user) { Fabricate(:user_admin) }

      before { sign_in(current_user) }

      User::VALID_EMPLOYEE_TYPES.each do |employee_type|
        context "when requested user is a #{employee_type}" do
          let(:user) { Fabricate("user_#{employee_type.downcase}") }

          it "returns a success response" do
            get :new, params: { user_id: user.to_param }
            expect(response).to be_successful
          end
        end
      end

      context "when requested user doesn't have an employee_type" do
        let(:user) { Fabricate(:user_unemployed) }

        it "returns a success response" do
          get :new, params: { user_id: user.to_param }
          expect(response).to be_successful
        end
      end

      context "when requested user is current_user" do
        it "should be unauthorized" do
          get :new, params: { user_id: current_user.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        User::VALID_EMPLOYEE_TYPES.each do |t|
          context "when requested user is a #{employee_type}" do
            let(:user) { Fabricate("user_#{t.downcase}") }

            it "should be unauthorized" do
              get :new, params: { user_id: user.to_param }
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "when requested user is a non employee" do
          let(:user) { Fabricate(:user_unemployed) }

          it "should be unauthorized" do
            get :new, params: { user_id: user.to_param }
            expect_to_be_unauthorized(response)
          end
        end

        context "when requested users is current_user" do
          it "should be unauthorized" do
            get :new, params: { user_id: current_user.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "GET #edit" do
    context "for an admin" do
      let(:current_user) { Fabricate(:user_admin) }

      before { sign_in(current_user) }

      User::VALID_EMPLOYEE_TYPES.each do |employee_type|
        context "when requested user is a #{employee_type}" do
          let(:user) { Fabricate("user_#{employee_type.downcase}") }

          it "returns a success response" do
            get :edit, params: { user_id: user.to_param }
            expect(response).to be_successful
          end
        end
      end

      context "when requested user doesn't have an employee_type" do
        let(:user) { Fabricate(:user_unemployed) }

        it "returns a success response" do
          get :edit, params: { user_id: user.to_param }
          expect(response).to be_successful
        end
      end

      context "when requested user is current_user" do
        it "should be unauthorized" do
          get :edit, params: { user_id: current_user.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        User::VALID_EMPLOYEE_TYPES.each do |t|
          context "when requested user is a #{employee_type}" do
            let(:user) { Fabricate("user_#{t.downcase}") }

            it "should be unauthorized" do
              get :edit, params: { user_id: user.to_param }
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "when requested user is a non employee" do
          let(:user) { Fabricate(:user_unemployed) }

          it "should be unauthorized" do
            get :edit, params: { user_id: user.to_param }
            expect_to_be_unauthorized(response)
          end
        end

        context "when requested users is current_user" do
          it "should be unauthorized" do
            get :edit, params: { user_id: current_user.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "PUT #create" do
    context "for an admin" do
      let(:current_user) { Fabricate(:user_admin) }

      before { sign_in(current_user) }

      context "when requested user is a another user" do
        context "with valid params" do
          it "updates the requested user" do
            user = Fabricate(:user_unemployed)
            expect do
              post :create, params: { user_id: user.to_param,
                                      user: valid_params }
              user.reload
            end.to change(user, :employee_type).to("Worker")
          end

          it "redirects to users" do
            user = Fabricate(:user_unemployed)
            post :create, params: { user_id: user.to_param, user: valid_params }
            expect(response)
              .to redirect_to(users_url(anchor: "user-#{user.id}"))
          end
        end
      end

      context "when requested user is current_user" do
        it "doesn't update the requested user" do
          expect do
            post :create, params: { user_id: current_user.to_param,
                                    user: valid_params }
            current_user.reload
          end.not_to change(current_user, :employee_type)
        end

        it "should be unauthorized" do
          post :create, params: { user_id: current_user.to_param,
                                  user: valid_params }
          expect_to_be_unauthorized(response)
        end
      end

      context "when requested user is has an employe_type" do
        let(:user) { Fabricate(:user_reporter) }

        it "updates the requested user" do
          expect do
            post :create, params: { user_id: user.to_param, user: valid_params }
            user.reload
          end.to change(user, :employee_type).to("Worker")
        end

        it "redirects to users" do
          post :create, params: { user_id: user.to_param, user: valid_params }
          expect(response)
            .to redirect_to(users_url(anchor: "user-#{user.id}"))
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when requested user is another user" do
          it "doesn't update the requested user" do
            user = Fabricate(:user_reporter)
            expect do
              post :create, params: { user_id: user.to_param,
                                      user: valid_params }
              user.reload
            end.not_to change(user, :employee_type)
          end

          it "should be unauthorized" do
            user = Fabricate(:user_reporter)
            post :create, params: { user_id: user.to_param, user: valid_params }
            expect_to_be_unauthorized(response)
          end
        end

        context "when requested user is current_user" do
          it "doesn't update the requested user" do
            expect do
              post :create, params: { user_id: current_user.to_param,
                                      user: valid_params }
              current_user.reload
            end.not_to change(current_user, :employee_type)
          end

          it "should be unauthorized" do
            post :create, params: { user_id: current_user.to_param,
                                    user: valid_params }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "PUT #update" do
    context "for an admin" do
      let(:current_user) { Fabricate(:user_admin) }

      before { sign_in(current_user) }

      context "when requested user is a another user" do
        context "with valid params" do
          it "updates the requested user" do
            user = Fabricate(:user_reporter)
            expect do
              put :update, params: { user_id: user.to_param,
                                     user: valid_params }
              user.reload
            end.to change(user, :employee_type).to("Worker")
          end

          it "redirects to users" do
            user = Fabricate(:user_reporter)
            put :update, params: { user_id: user.to_param, user: valid_params }
            expect(response)
              .to redirect_to(users_url(anchor: "user-#{user.id}"))
          end
        end
      end

      context "when requested user is current_user" do
        it "doesn't update the requested user" do
          expect do
            put :update, params: { user_id: current_user.to_param,
                                   user: valid_params }
            current_user.reload
          end.not_to change(current_user, :employee_type)
        end

        it "should be unauthorized" do
          put :update, params: { user_id: current_user.to_param,
                                 user: valid_params }
          expect_to_be_unauthorized(response)
        end
      end

      context "when requested user is a non employee" do
        let(:user) { Fabricate(:user_unemployed) }

        it "updates the requested user" do
          expect do
            put :update, params: { user_id: user.to_param, user: valid_params }
            user.reload
          end.to change(user, :employee_type).to("Worker")
        end

        it "redirects to users" do
          put :update, params: { user_id: user.to_param, user: valid_params }
          expect(response)
            .to redirect_to(users_url(anchor: "user-#{user.id}"))
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when requested user is another user" do
          it "doesn't update the requested user" do
            user = Fabricate(:user_reporter)
            expect do
              put :update, params: { user_id: user.to_param,
                                     user: valid_params }
              user.reload
            end.not_to change(user, :employee_type)
          end

          it "should be unauthorized" do
            user = Fabricate(:user_reporter)
            put :update, params: { user_id: user.to_param, user: valid_params }
            expect_to_be_unauthorized(response)
          end
        end

        context "when requested user is current_user" do
          it "doesn't update the requested user" do
            expect do
              put :update, params: { user_id: current_user.to_param,
                                     user: valid_params }
              current_user.reload
            end.not_to change(current_user, :employee_type)
          end

          it "should be unauthorized" do
            put :update, params: { user_id: current_user.to_param,
                                   user: valid_params }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "for an admin" do
      let(:current_user) { Fabricate(:user_admin) }

      before { sign_in(current_user) }

      context "when requested user is another user" do
        it "updates the requested user" do
          user = Fabricate(:user)
          expect do
            delete :destroy, params: { user_id: user.to_param }
            user.reload
          end.to change(user, :employee_type).to(nil)
        end

        it "doesn't sign out the current_user" do
          user = Fabricate(:user)
          expect do
            delete :destroy, params: { user_id: user.to_param }
            user.reload
          end.not_to change(controller, :current_user)
        end

        it "redirects to users" do
          user = Fabricate(:user)
          delete :destroy, params: { user_id: user.to_param }
          expect(response)
            .to redirect_to(users_url(anchor: "user-#{user.id}"))
        end
      end

      context "when requested user is current_user" do
        it "doesn't update the requested user" do
          expect do
            delete :destroy, params: { user_id: current_user.to_param }
            current_user.reload
          end.not_to change(current_user, :employee_type)
        end

        it "should be unauthorized" do
          delete :destroy, params: { user_id: current_user.to_param }
          expect_to_be_unauthorized(response)
        end
      end

      context "when requested user is invalid" do
        let(:user) { Fabricate(:user) }

        before { user.update_attribute :name, nil }

        it "doesn't update the requested user" do
          expect do
            delete :destroy, params: { user_id: user.to_param }
            user.reload
          end.not_to change(user, :employee_type)
        end

        it "doesn't sign out the current_user" do
          expect do
            delete :destroy, params: { user_id: user.to_param }
            user.reload
          end.not_to change(controller, :current_user)
        end

        it "renders edit" do
          user = Fabricate(:user)
          user.update_attribute :name, nil
          delete :destroy, params: { user_id: user.to_param }
          expect(response).to be_successful
        end
      end

      context "when cancelling an non employee" do
        let(:user) { Fabricate(:user_unemployed) }

        it "doesn't update the requested user" do
          expect do
            delete :destroy, params: { user_id: user.to_param }
            user.reload
          end.not_to change(user, :employee_type).from(nil)
        end

        it "doesn't sign out the current_user" do
          expect do
            delete :destroy, params: { user_id: user.to_param }
            user.reload
          end.not_to change(controller, :current_user)
        end

        it "redirects to users" do
          delete :destroy, params: { user_id: user.to_param }
          expect(response)
            .to redirect_to(users_url(anchor: "user-#{user.id}"))
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when requested user is another user" do
          it "doesn't update the requested user" do
            user = Fabricate(:user)
            expect do
              delete :destroy, params: { user_id: user.to_param }
              user.reload
            end.not_to change(user, :employee_type)
          end

          it "should be unauthorized" do
            user = Fabricate(:user)
            delete :destroy, params: { user_id: user.to_param }
            expect_to_be_unauthorized(response)
          end
        end

        context "when requested user is current_user" do
          it "updates the requested user" do
            expect do
              delete :destroy, params: { user_id: current_user.to_param }
              current_user.reload
            end.to change(current_user, :employee_type).to(nil)
          end

          it "signs out the user" do
            expect do
              delete :destroy, params: { user_id: current_user.to_param }
              current_user.reload
            end.to change(controller, :current_user).to(nil)
          end

          it "redirects to sign in" do
            delete :destroy, params: { user_id: current_user.to_param }
            expect(response).to redirect_to(new_user_session_path)
          end
        end
      end
    end
  end
end
