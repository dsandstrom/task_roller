# frozen_string_literal: true

require "rails_helper"

RSpec.describe CancelUsersController, type: :controller do
  describe "GET #edit" do
    context "for an admin" do
      let(:current_user) { Fabricate(:user_admin) }

      before { sign_in(current_user) }

      User::VALID_EMPLOYEE_TYPES.each do |employee_type|
        context "when requested user is a #{employee_type}" do
          let(:user) { Fabricate("user_#{employee_type.downcase}") }

          it "returns a success response" do
            get :edit, params: { id: user.to_param }
            expect(response).to be_successful
          end
        end
      end

      context "when requested user doesn't have an employee_type" do
        let(:user) { Fabricate(:user_unemployed) }

        it "returns a success response" do
          get :edit, params: { id: user.to_param }
          expect(response).to be_successful
        end
      end

      context "when requested user is current_user" do
        it "should be unauthorized" do
          get :edit, params: { id: current_user.to_param }
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
              get :edit, params: { id: user.to_param }
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "when requested user is a non employee" do
          let(:user) { Fabricate(:user_unemployed) }

          it "should be unauthorized" do
            get :edit, params: { id: user.to_param }
            expect_to_be_unauthorized(response)
          end
        end

        context "when requested users is current_user" do
          it "returns a success response" do
            get :edit, params: { id: current_user.to_param }
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "PUT #update" do
    context "for an admin" do
      let(:current_user) { Fabricate(:user_admin) }

      before { sign_in(current_user) }

      context "when cancelling another user" do
        it "updates the requested user" do
          user = Fabricate(:user)
          expect do
            put :update, params: { id: user.to_param }
            user.reload
          end.to change(user, :employee_type).to(nil)
        end

        it "doesn't sign out the current_user" do
          user = Fabricate(:user)
          expect do
            put :update, params: { id: user.to_param }
            user.reload
          end.not_to change(controller, :current_user)
        end

        it "redirects to users" do
          user = Fabricate(:user)
          put :update, params: { id: user.to_param }
          expect(response).to redirect_to(:users)
        end
      end

      context "when cancelling themselves" do
        it "doesn't update the requested user" do
          expect do
            put :update, params: { id: current_user.to_param }
            current_user.reload
          end.not_to change(current_user, :employee_type)
        end

        it "should be unauthorized" do
          put :update, params: { id: current_user.to_param }
          expect_to_be_unauthorized(response)
        end
      end

      context "when cancelling an invalid user" do
        let(:user) { Fabricate(:user) }

        before { user.update_attribute :name, nil }

        it "doesn't update the requested user" do
          expect do
            put :update, params: { id: user.to_param }
            user.reload
          end.not_to change(user, :employee_type)
        end

        it "doesn't sign out the current_user" do
          expect do
            put :update, params: { id: user.to_param }
            user.reload
          end.not_to change(controller, :current_user)
        end

        it "renders edit" do
          user = Fabricate(:user)
          user.update_attribute :name, nil
          put :update, params: { id: user.to_param }
          expect(response).to be_successful
        end
      end

      context "when cancelling an non employee" do
        let(:user) { Fabricate(:user_unemployed) }

        it "doesn't update the requested user" do
          expect do
            put :update, params: { id: user.to_param }
            user.reload
          end.not_to change(user, :employee_type).from(nil)
        end

        it "doesn't sign out the current_user" do
          expect do
            put :update, params: { id: user.to_param }
            user.reload
          end.not_to change(controller, :current_user)
        end

        it "redirects to users" do
          put :update, params: { id: user.to_param }
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
              put :update, params: { id: user.to_param }
              user.reload
            end.not_to change(user, :employee_type)
          end

          it "should be unauthorized" do
            user = Fabricate(:user)
            put :update, params: { id: user.to_param }
            expect_to_be_unauthorized(response)
          end
        end

        context "when cancelling themselves" do
          it "updates the requested user" do
            expect do
              put :update, params: { id: current_user.to_param }
              current_user.reload
            end.to change(current_user, :employee_type).to(nil)
          end

          it "signs out the user" do
            expect do
              put :update, params: { id: current_user.to_param }
              current_user.reload
            end.to change(controller, :current_user).to(nil)
          end

          it "redirects to sign in" do
            put :update, params: { id: current_user.to_param }
            expect(response).to redirect_to(new_user_session_path)
          end
        end
      end
    end
  end
end
