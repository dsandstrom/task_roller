# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProjectTasksSubscriptionsController, type: :controller do
  let(:project) { Fabricate(:project) }
  let(:user) { Fabricate(:user_worker) }

  describe "GET #new" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        it "returns a success response" do
          get :new, params: { project_id: project.to_param }
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

        context "when html request" do
          context "with valid params" do
            it "creates a new ProjectTasksSubscription" do
              expect do
                post :create, params: { project_id: project.to_param }
              end.to change(current_user.project_tasks_subscriptions, :count)
                .by(1)
            end

            it "redirects to the requested project" do
              post :create, params: { project_id: project.to_param }
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
                post :create, params: { project_id: project.to_param }
              end.not_to change(ProjectTasksSubscription, :count)
            end

            it "renders new" do
              post :create, params: { project_id: project.to_param }
              expect(response).to be_successful
            end
          end
        end

        context "when js request" do
          context "with valid params" do
            it "creates a new ProjectTasksSubscription" do
              expect do
                post :create, params: { project_id: project.to_param },
                              xhr: true
              end.to change(current_user.project_tasks_subscriptions, :count)
                .by(1)
            end

            it "renders :show" do
              post :create, params: { project_id: project.to_param },
                            xhr: true
              expect(response).to be_successful
            end
          end

          context "with invalid params" do
            before do
              Fabricate(:project_tasks_subscription, project: project,
                                                     user: current_user)
            end

            it "doesn't create a new ProjectTasksSubscription" do
              expect do
                post :create, params: { project_id: project.to_param },
                              xhr: true
              end.not_to change(ProjectTasksSubscription, :count)
            end

            it "renders new" do
              post :create, params: { project_id: project.to_param },
                            xhr: true
              expect(response).to be_successful
            end
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

        context "when html request" do
          context "when their project_tasks_subscription" do
            it "destroys the requested project_tasks_subscription" do
              subscription =
                Fabricate(:project_tasks_subscription, project: project,
                                                       user: current_user)
              expect do
                delete :destroy, params: { project_id: project.to_param,
                                           id: subscription.to_param }
              end.to change(current_user.project_tasks_subscriptions, :count)
                .by(-1)
            end

            it "redirects to the requested project" do
              subscription =
                Fabricate(:project_tasks_subscription, project: project,
                                                       user: current_user)
              delete :destroy, params: { project_id: project.to_param,
                                         id: subscription.to_param }
              expect(response).to redirect_to(project)
            end
          end

          context "when someone else's project_tasks_subscription" do
            it "doesn't destroys the requested project_tasks_subscription" do
              subscription =
                Fabricate(:project_tasks_subscription, project: project)
              expect do
                delete :destroy, params: { project_id: project.to_param,
                                           id: subscription.to_param }
              end.not_to change(TaskSubscription, :count)
            end

            it "should be unauthorized" do
              subscription =
                Fabricate(:project_tasks_subscription, project: project)
              delete :destroy, params: { project_id: project.to_param,
                                         id: subscription.to_param }
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "when js request" do
          context "when their project_tasks_subscription" do
            it "destroys the requested project_tasks_subscription" do
              subscription =
                Fabricate(:project_tasks_subscription, project: project,
                                                       user: current_user)
              expect do
                delete :destroy, params: { project_id: project.to_param,
                                           id: subscription.to_param },
                                 xhr: true
              end.to change(current_user.project_tasks_subscriptions, :count)
                .by(-1)
            end

            it "renders :new" do
              subscription =
                Fabricate(:project_tasks_subscription, project: project,
                                                       user: current_user)
              delete :destroy, params: { project_id: project.to_param,
                                         id: subscription.to_param },
                               xhr: true
              expect(response).to be_successful
            end
          end

          context "when someone else's project_tasks_subscription" do
            it "doesn't destroys the requested project_tasks_subscription" do
              subscription =
                Fabricate(:project_tasks_subscription, project: project)
              expect do
                delete :destroy, params: { project_id: project.to_param,
                                           id: subscription.to_param },
                                 xhr: true
              end.not_to change(TaskSubscription, :count)
            end

            it "should be unauthorized" do
              subscription =
                Fabricate(:project_tasks_subscription, project: project)
              delete :destroy, params: { project_id: project.to_param,
                                         id: subscription.to_param },
                               xhr: true
              expect(response).to have_http_status(:forbidden)
            end
          end
        end
      end
    end
  end
end
