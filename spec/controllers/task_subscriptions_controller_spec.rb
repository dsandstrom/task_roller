# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskSubscriptionsController, type: :controller do
  let(:task) { Fabricate(:task) }

  describe "GET #new" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        it "returns a success response" do
          get :new, params: { task_id: task.to_param }
          expect(response).to be_successful
        end
      end
    end
  end

  describe "POST #create" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "with valid params" do
          it "creates a new TaskSubscription" do
            expect do
              post :create, params: { task_id: task.to_param }
            end.to change(current_user.task_subscriptions, :count).by(1)
          end

          it "redirects to the requested task" do
            post :create, params: { task_id: task.to_param }
            expect(response).to redirect_to(task)
          end
        end

        context "with invalid params" do
          before do
            Fabricate(:task_subscription, task: task, user: current_user)
          end

          it "doesn't create a new TaskSubscription" do
            expect do
              post :create, params: { task_id: task.to_param }
            end.not_to change(TaskSubscription, :count)
          end

          it "renders new" do
            post :create, params: { task_id: task.to_param }
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

        before { sign_in(current_user) }

        context "when their task_subscription" do
          it "destroys the requested task_subscription" do
            task_subscription =
              Fabricate(:task_subscription, task: task, user: current_user)
            expect do
              delete :destroy, params: { task_id: task.to_param,
                                         id: task_subscription.to_param }
            end.to change(current_user.task_subscriptions, :count).by(-1)
          end

          it "redirects to the task_subscriptions list" do
            task_subscription =
              Fabricate(:task_subscription, task: task, user: current_user)
            delete :destroy, params: { task_id: task.to_param,
                                       id: task_subscription.to_param }
            expect(response).to redirect_to(task)
          end
        end

        context "when someone else's task_subscription" do
          it "doesn't destroys the requested task_subscription" do
            task_subscription = Fabricate(:task_subscription, task: task)
            expect do
              delete :destroy, params: { task_id: task.to_param,
                                         id: task_subscription.to_param }
            end.not_to change(TaskSubscription, :count)
          end

          it "should be unauthorized" do
            task_subscription = Fabricate(:task_subscription, task: task)
            delete :destroy, params: { task_id: task.to_param,
                                       id: task_subscription.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end
end
