require "rails_helper"

RSpec.describe ProjectTasksSubscriptionsController, type: :controller do
  let(:project) { Fabricate(:project) }
  let(:user) { Fabricate(:user_worker) }

  describe "GET #new" do
    let(:params) { { project_id: project.to_param } }

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "when html request" do
        context "for a #{employee_type}" do
          let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

          before { sign_in(current_user) }

          it "returns a success response" do
            get :new, params: params
            expect(response).to be_successful
          end
        end
      end

      context "when turbo_stream request" do
        context "for a #{employee_type}" do
          let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

          before { sign_in(current_user) }

          it "returns a success response" do
            get :new, params: params, as: :turbo_stream
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "POST #create" do
    let(:params) { { project_id: project.to_param } }

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when html request" do
          context "with valid params" do
            it "creates a new ProjectTasksSubscription" do
              expect do
                post :create, params: params
              end.to change(current_user.project_tasks_subscriptions, :count)
                .by(1)
            end

            it "redirects to the requested project" do
              post :create, params: params
              expect(response).to redirect_to(project)
            end
          end

          context "with invalid params" do
            before do
              Fabricate(:project_tasks_subscription, project: project,
                                                     user: current_user)
            end

            it "doesn't create a new ProjectTasksSubscription" do
              expect do
                post :create, params: params
              end.not_to change(ProjectTasksSubscription, :count)
            end

            it "renders new" do
              post :create, params: params
              expect(response).to be_successful
            end
          end
        end

        context "when turbo_stream request" do
          context "with valid params" do
            it "creates a new ProjectTasksSubscription" do
              expect do
                post :create, params: params, as: :turbo_stream
              end.to change(current_user.project_tasks_subscriptions, :count)
                .by(1)
            end

            it "redirects to the requested project" do
              post :create, params: params, as: :turbo_stream
              expect(response).to redirect_to(project)
            end
          end

          context "with invalid params" do
            before do
              Fabricate(:project_tasks_subscription, project: project,
                                                     user: current_user)
            end

            it "doesn't create a new ProjectTasksSubscription" do
              expect do
                post :create, params: params, as: :turbo_stream
              end.not_to change(ProjectTasksSubscription, :count)
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
    let(:params) { { project_id: project.to_param, id: subscription.to_param } }

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when html request" do
          context "when their project_tasks_subscription" do
            let!(:subscription) do
              Fabricate(:project_tasks_subscription, project: project,
                                                     user: current_user)
            end

            it "destroys the requested project_tasks_subscription" do
              expect do
                delete :destroy, params: params
              end.to change(current_user.project_tasks_subscriptions, :count)
                .by(-1)
            end

            it "redirects to the requested project" do
              delete :destroy, params: params
              expect(response).to redirect_to(project)
            end
          end

          context "when someone else's project_tasks_subscription" do
            let!(:subscription) do
              Fabricate(:project_tasks_subscription, project: project)
            end

            it "doesn't destroys the requested project_tasks_subscription" do
              expect do
                delete :destroy, params: params
              end.not_to change(ProjectTasksSubscription, :count)
            end

            it "should be unauthorized" do
              delete :destroy, params: params
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "when turbo_stream request" do
          context "when their project_tasks_subscription" do
            let!(:subscription) do
              Fabricate(:project_tasks_subscription, project: project,
                                                     user: current_user)
            end

            it "destroys the requested project_tasks_subscription" do
              expect do
                delete :destroy, params: params, as: :turbo_stream
              end.to change(current_user.project_tasks_subscriptions, :count)
                .by(-1)
            end

            it "redirects to the requested project" do
              delete :destroy, params: params, as: :turbo_stream
              expect(response).to redirect_to(project)
            end
          end

          context "when someone else's project_tasks_subscription" do
            let!(:subscription) do
              Fabricate(:project_tasks_subscription, project: project)
            end

            it "doesn't destroys the requested project_tasks_subscription" do
              expect do
                delete :destroy, params: params, as: :turbo_stream
              end.not_to change(ProjectTasksSubscription, :count)
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
