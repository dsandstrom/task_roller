# frozen_string_literal: true

require "rails_helper"

RSpec.describe CategoryTaskSubscriptionsController, type: :controller do
  let(:category) { Fabricate(:category) }
  let(:user) { Fabricate(:user_worker) }

  describe "GET #new" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { login(current_user) }

        it "returns a success response" do
          get :new, params: { category_id: category.to_param }
          expect(response).to be_successful
        end
      end
    end
  end

  describe "POST #create" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { login(current_user) }

        context "with valid params" do
          it "creates a new CategoryTaskSubscription" do
            expect do
              post :create, params: { category_id: category.to_param }
            end.to change(current_user.category_task_subscriptions, :count)
              .by(1)
          end

          it "redirects to the requested category" do
            post :create, params: { category_id: category.to_param }
            expect(response).to redirect_to(category)
          end
        end

        context "with invalid params" do
          before do
            Fabricate(:category_task_subscription, category: category,
                                                   user: current_user)
          end

          it "doesn't create a new CategoryTaskSubscription" do
            expect do
              post :create, params: { category_id: category.to_param }
            end.not_to change(CategoryTaskSubscription, :count)
          end

          it "renders new" do
            post :create, params: { category_id: category.to_param }
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { login(current_user) }

        context "when their category_task_subscription" do
          it "destroys the requested category_task_subscription" do
            subscription =
              Fabricate(:category_task_subscription, category: category,
                                                     user: current_user)
            expect do
              delete :destroy, params: { category_id: category.to_param,
                                         id: subscription.to_param }
            end.to change(current_user.category_task_subscriptions, :count)
              .by(-1)
          end

          it "redirects to the requested category" do
            subscription =
              Fabricate(:category_task_subscription, category: category,
                                                     user: current_user)
            delete :destroy, params: { category_id: category.to_param,
                                       id: subscription.to_param }
            expect(response).to redirect_to(category)
          end
        end

        context "when someone else's category_task_subscription" do
          it "doesn't destroys the requested category_task_subscription" do
            subscription =
              Fabricate(:category_task_subscription, category: category)
            expect do
              delete :destroy, params: { category_id: category.to_param,
                                         id: subscription.to_param }
            end.not_to change(TaskSubscription, :count)
          end

          it "should be unauthorized" do
            subscription =
              Fabricate(:category_task_subscription, category: category)
            delete :destroy, params: { category_id: category.to_param,
                                       id: subscription.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end
end
