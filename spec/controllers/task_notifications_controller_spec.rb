# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskNotificationsController, type: :controller do
  let(:task) { Fabricate(:closed_task) }

  describe "DELETE #destroy" do
    let(:task) { Fabricate(:task) }

    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when requested task_notification belongs to them" do
          context "for an html request" do
            it "destroys the requested task_notification" do
              task_notification = Fabricate(:task_notification,
                                            task: task, user: current_user)
              expect do
                delete :destroy, params: { id: task_notification.to_param }
              end.to change(TaskNotification, :count).by(-1)
            end

            it "redirects to the task" do
              task_notification = Fabricate(:task_notification,
                                            task: task, user: current_user)
              delete :destroy, params: { id: task_notification.to_param }
              expect(response).to redirect_to(task)
            end
          end

          context "for an ajax request" do
            it "destroys the requested task_notification" do
              task_notification = Fabricate(:task_notification,
                                            task: task, user: current_user)
              expect do
                delete :destroy, params: { id: task_notification.to_param },
                                 xhr: true
              end.to change(TaskNotification, :count).by(-1)
            end

            it "renders destroy" do
              task_notification = Fabricate(:task_notification,
                                            task: task, user: current_user)
              delete :destroy, params: { id: task_notification.to_param },
                               xhr: true
              expect(response).to be_successful
            end
          end
        end

        context "when requested task_notification doesn't belong to them" do
          it "doesn't destroy the requested task_notification" do
            task_notification = Fabricate(:task_notification, task: task)
            expect do
              delete :destroy, params: { id: task_notification.to_param }
            end.not_to change(TaskNotification, :count)
          end

          it "redirects to unauthorized" do
            task_notification = Fabricate(:task_notification, task: task)
            delete :destroy, params: { id: task_notification.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when requested task_notification belongs to them" do
          it "destroys the requested task_notification" do
            task_notification = Fabricate(:task_notification,
                                          task: task, user: current_user)
            expect do
              delete :destroy, params: { id: task_notification.to_param }
            end.to change(TaskNotification, :count).by(-1)
          end

          it "redirects to the task" do
            task_notification = Fabricate(:task_notification,
                                          task: task, user: current_user)
            delete :destroy, params: { id: task_notification.to_param }
            expect(response).to redirect_to(task)
          end
        end

        context "when requested task_notification doesn't belong to them" do
          it "doesn't destroy the requested task_notification" do
            task_notification = Fabricate(:task_notification, task: task)
            expect do
              delete :destroy, params: { id: task_notification.to_param }
            end.not_to change(TaskNotification, :count)
          end

          it "redirects to unauthorized" do
            task_notification = Fabricate(:task_notification, task: task)
            delete :destroy, params: { id: task_notification.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end
end
