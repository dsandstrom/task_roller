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
          let!(:task_notification) do
            Fabricate(:task_notification, task: task, user: current_user)
          end

          context "for an html request" do
            it "destroys the requested task_notification" do
              expect do
                delete :destroy, params: { id: task_notification.to_param }
              end.to change(TaskNotification, :count).by(-1)
            end

            it "redirects to the task" do
              delete :destroy, params: { id: task_notification.to_param }
              expect(response).to redirect_to(task)
            end
          end

          context "for a turbo_stream request" do
            it "destroys the requested task_notification" do
              expect do
                delete :destroy, params: { id: task_notification.to_param },
                                 as: :turbo_stream
              end.to change(TaskNotification, :count).by(-1)
            end

            it "redirects to the task" do
              delete :destroy, params: { id: task_notification.to_param },
                               as: :turbo_stream
              expect(response).to redirect_to(task)
            end
          end
        end

        context "when requested task_notification doesn't belong to them" do
          let!(:task_notification) { Fabricate(:task_notification, task: task) }

          context "for an html request" do
            it "doesn't destroy the requested task_notification" do
              expect do
                delete :destroy, params: { id: task_notification.to_param }
              end.not_to change(TaskNotification, :count)
            end

            it "redirects to unauthorized" do
              delete :destroy, params: { id: task_notification.to_param }
              expect_to_be_unauthorized(response)
            end
          end

          context "for a turbo_stream request" do
            it "doesn't destroy the requested task_notification" do
              expect do
                delete :destroy, params: { id: task_notification.to_param },
                                 as: :turbo_stream
              end.not_to change(TaskNotification, :count)
            end

            it "redirects to unauthorized" do
              delete :destroy, params: { id: task_notification.to_param },
                               as: :turbo_stream
              expect(response).to have_http_status(403)
            end
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when requested task_notification belongs to them" do
          let!(:task_notification) do
            Fabricate(:task_notification, task: task, user: current_user)
          end

          context "for an html request" do
            it "destroys the requested task_notification" do
              expect do
                delete :destroy, params: { id: task_notification.to_param }
              end.to change(TaskNotification, :count).by(-1)
            end

            it "redirects to the task" do
              delete :destroy, params: { id: task_notification.to_param }
              expect(response).to redirect_to(task)
            end
          end
        end

        context "when requested task_notification doesn't belong to them" do
          let!(:task_notification) { Fabricate(:task_notification, task: task) }

          context "for an html request" do
            it "doesn't destroy the requested task_notification" do
              expect do
                delete :destroy, params: { id: task_notification.to_param }
              end.not_to change(TaskNotification, :count)
            end

            it "redirects to unauthorized" do
              delete :destroy, params: { id: task_notification.to_param }
              expect_to_be_unauthorized(response)
            end
          end
        end
      end
    end
  end

  describe "DELETE #bulk_destroy" do
    let(:task) { Fabricate(:task) }

    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when they have notifications for the requested task" do
          before do
            Fabricate(:task_notification, task: task)
            Fabricate(:task_notification, task: task, user: current_user)
          end

          context "for an html request" do
            it "destroys the requested task's notifications" do
              expect do
                delete :bulk_destroy, params: { task_id: task.to_param }
              end.to change(TaskNotification, :count).by(-1)
            end

            it "redirects to the task" do
              delete :bulk_destroy, params: { task_id: task.to_param }
              expect(response).to redirect_to(task)
            end
          end

          context "for a turbo_stream request" do
            it "destroys the requested task's notifications" do
              expect do
                delete :bulk_destroy, params: { task_id: task.to_param },
                                      as: :turbo_stream
              end.to change(TaskNotification, :count).by(-1)
            end

            it "renders :bulk_destroy" do
              delete :bulk_destroy, params: { task_id: task.to_param },
                                    as: :turbo_stream
              expect(response).to be_successful
            end
          end
        end

        context "when no task_notifications" do
          before { Fabricate(:task_notification, task: task) }

          context "for an html request" do
            it "doesn't destroy the requested task's notifications" do
              expect do
                delete :bulk_destroy, params: { task_id: task.to_param }
              end.not_to change(TaskNotification, :count)
            end

            it "redirects to the task" do
              delete :bulk_destroy, params: { task_id: task.to_param }
              expect(response).to redirect_to(task)
            end
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when they have notifications for the requested task" do
          before do
            Fabricate(:task_notification, task: task)
            Fabricate(:task_notification, task: task, user: current_user)
          end

          context "for an html request" do
            it "destroys the requested task's notifications" do
              expect do
                delete :bulk_destroy, params: { task_id: task.to_param }
              end.to change(TaskNotification, :count).by(-1)
            end

            it "redirects to the task" do
              delete :bulk_destroy, params: { task_id: task.to_param }
              expect(response).to redirect_to(task)
            end
          end

          context "for a turbo_stream request" do
            it "destroys the requested task's notifications" do
              expect do
                delete :bulk_destroy, params: { task_id: task.to_param },
                                      as: :turbo_stream
              end.to change(TaskNotification, :count).by(-1)
            end

            it "renders success" do
              delete :bulk_destroy, params: { task_id: task.to_param },
                                    as: :turbo_stream
              expect(response).to be_successful
            end
          end
        end

        context "when no task_notifications" do
          before { Fabricate(:task_notification, task: task) }

          context "for an html request" do
            it "doesn't destroy the requested task's notifications" do
              expect do
                delete :bulk_destroy, params: { task_id: task.to_param }
              end.not_to change(TaskNotification, :count)
            end

            it "redirects to the task" do
              delete :bulk_destroy, params: { task_id: task.to_param }
              expect(response).to redirect_to(task)
            end
          end

          context "for a turbo_stream request" do
            it "doesn't destroy the requested task's notifications" do
              expect do
                delete :bulk_destroy, params: { task_id: task.to_param },
                                      as: :turbo_stream
              end.not_to change(TaskNotification, :count)
            end

            it "renders success" do
              delete :bulk_destroy, params: { task_id: task.to_param },
                                    as: :turbo_stream
              expect(response).to be_successful
            end
          end
        end

        context "when requested task is invisible" do
          let(:project) { Fabricate(:invisible_project) }
          let(:task) { Fabricate(:task, project: project) }

          before do
            Fabricate(:task_notification, task: task, user: current_user)
          end

          context "for an html request" do
            it "doesn't destroy the requested task's notifications" do
              expect do
                delete :bulk_destroy, params: { task_id: task.to_param }
              end.not_to change(TaskNotification, :count)
            end

            it "should be unauthorized" do
              delete :bulk_destroy, params: { task_id: task.to_param }
              expect_to_be_unauthorized(response)
            end
          end

          context "for a turbo_stream request" do
            it "doesn't destroy the requested task's notifications" do
              expect do
                delete :bulk_destroy, params: { task_id: task.to_param },
                                      as: :turbo_stream
              end.not_to change(TaskNotification, :count)
            end

            it "should be unauthorized" do
              delete :bulk_destroy, params: { task_id: task.to_param },
                                    as: :turbo_stream
              expect(response).to have_http_status(403)
            end
          end
        end
      end
    end
  end
end
