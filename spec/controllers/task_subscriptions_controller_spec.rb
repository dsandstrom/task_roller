require "rails_helper"

RSpec.describe TaskSubscriptionsController, type: :controller do
  let(:task) { Fabricate(:task) }

  describe "GET #new" do
    let(:params) { { task_id: task.to_param } }

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when html request" do
          it "returns a success response" do
            get :new, params: params
            expect(response).to be_successful
          end
        end

        context "when turbo_stream request" do
          it "returns a success response" do
            get :new, params: params, as: :turbo_stream
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "POST #create" do
    let(:params) { { task_id: task.to_param } }

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when html request" do
          context "with valid params" do
            it "creates a new TaskSubscription" do
              expect do
                post :create, params: params
              end.to change(current_user.task_subscriptions, :count).by(1)
            end

            it "redirects to the requested task" do
              post :create, params: params
              expect(response).to redirect_to(task)
            end
          end

          context "with invalid params" do
            before do
              Fabricate(:task_subscription, task: task, user: current_user)
            end

            it "doesn't create a new TaskSubscription" do
              expect do
                post :create, params: params
              end.not_to change(TaskSubscription, :count)
            end

            it "renders new" do
              post :create, params: params
              expect(response).to be_successful
            end
          end
        end

        context "when turbo_stream request" do
          context "with valid params" do
            it "creates a new TaskSubscription" do
              expect do
                post :create, params: params, as: :turbo_stream
              end.to change(current_user.task_subscriptions, :count).by(1)
            end

            it "redirects to the requested task" do
              post :create, params: params, as: :turbo_stream
              expect(response).to redirect_to(task)
            end
          end

          context "with invalid params" do
            before do
              Fabricate(:task_subscription, task: task, user: current_user)
            end

            it "doesn't create a new TaskSubscription" do
              expect do
                post :create, params: params, as: :turbo_stream
              end.not_to change(TaskSubscription, :count)
            end

            it "renders new" do
              post :create, params: params, as: :turbo_stream
              expect(response).to be_successful
            end
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:params) { { task_id: task.to_param, id: task_subscription.to_param } }

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when html request" do
          context "when their task_subscription" do
            let!(:task_subscription) do
              Fabricate(:task_subscription, task: task, user: current_user)
            end

            it "destroys the requested task_subscription" do
              expect do
                delete :destroy, params: params
              end.to change(current_user.task_subscriptions, :count).by(-1)
            end

            it "redirects to the task_subscriptions list" do
              delete :destroy, params: params
              expect(response).to redirect_to(task)
            end
          end

          context "when someone else's task_subscription" do
            let!(:task_subscription) do
              Fabricate(:task_subscription, task: task)
            end

            it "doesn't destroys the requested task_subscription" do
              expect do
                delete :destroy, params: params
              end.not_to change(TaskSubscription, :count)
            end

            it "should be unauthorized" do
              delete :destroy, params: params
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "when turbo_stream request" do
          context "when their task_subscription" do
            let!(:task_subscription) do
              Fabricate(:task_subscription, task: task, user: current_user)
            end

            it "destroys the requested task_subscription" do
              expect do
                delete :destroy, params: params, as: :turbo_stream
              end.to change(current_user.task_subscriptions, :count).by(-1)
            end

            it "redirects to the task_subscriptions list" do
              delete :destroy, params: params, as: :turbo_stream
              expect(response).to redirect_to(task)
            end
          end

          context "when someone else's task_subscription" do
            let!(:task_subscription) do
              Fabricate(:task_subscription, task: task)
            end

            it "doesn't destroys the requested task_subscription" do
              expect do
                delete :destroy, params: params, as: :turbo_stream
              end.not_to change(TaskSubscription, :count)
            end

            it "should be unauthorized" do
              delete :destroy, params: params, as: :turbo_stream
              expect(response).to have_http_status(:forbidden)
            end
          end
        end
      end
    end
  end
end
