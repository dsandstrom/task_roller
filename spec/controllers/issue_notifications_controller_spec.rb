# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueNotificationsController, type: :controller do
  let(:issue) { Fabricate(:closed_issue) }

  describe "DELETE #destroy" do
    let(:issue) { Fabricate(:issue) }

    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when requested issue_notification belongs to them" do
          context "for an html request" do
            it "destroys the requested issue_notification" do
              issue_notification = Fabricate(:issue_notification,
                                             issue: issue, user: current_user)
              expect do
                delete :destroy, params: { id: issue_notification.to_param }
              end.to change(IssueNotification, :count).by(-1)
            end

            it "redirects to the issue" do
              issue_notification = Fabricate(:issue_notification,
                                             issue: issue, user: current_user)
              delete :destroy, params: { id: issue_notification.to_param }
              expect(response).to redirect_to(issue)
            end
          end

          context "for an ajax request" do
            it "destroys the requested issue_notification" do
              issue_notification = Fabricate(:issue_notification,
                                             issue: issue, user: current_user)
              expect do
                delete :destroy, params: { id: issue_notification.to_param },
                                 xhr: true
              end.to change(IssueNotification, :count).by(-1)
            end

            it "renders :destroy" do
              issue_notification = Fabricate(:issue_notification,
                                             issue: issue, user: current_user)
              delete :destroy, params: { id: issue_notification.to_param },
                               xhr: true
              expect(response).to be_successful
            end
          end
        end

        context "when requested issue_notification doesn't belong to them" do
          it "doesn't destroy the requested issue_notification" do
            issue_notification = Fabricate(:issue_notification, issue: issue)
            expect do
              delete :destroy, params: { id: issue_notification.to_param }
            end.not_to change(IssueNotification, :count)
          end

          it "redirects to unauthorized" do
            issue_notification = Fabricate(:issue_notification, issue: issue)
            delete :destroy, params: { id: issue_notification.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when requested issue_notification belongs to them" do
          it "destroys the requested issue_notification" do
            issue_notification = Fabricate(:issue_notification,
                                           issue: issue, user: current_user)
            expect do
              delete :destroy, params: { id: issue_notification.to_param }
            end.to change(IssueNotification, :count).by(-1)
          end

          it "redirects to the issue" do
            issue_notification = Fabricate(:issue_notification,
                                           issue: issue, user: current_user)
            delete :destroy, params: { id: issue_notification.to_param }
            expect(response).to redirect_to(issue)
          end
        end

        context "when requested issue_notification doesn't belong to them" do
          it "doesn't destroy the requested issue_notification" do
            issue_notification = Fabricate(:issue_notification, issue: issue)
            expect do
              delete :destroy, params: { id: issue_notification.to_param }
            end.not_to change(IssueNotification, :count)
          end

          it "redirects to unauthorized" do
            issue_notification = Fabricate(:issue_notification, issue: issue)
            delete :destroy, params: { id: issue_notification.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "DELETE #bulk_destroy" do
    let(:issue) { Fabricate(:issue) }

    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when they have notifications for the requested issue" do
          before do
            Fabricate(:issue_notification, issue: issue)
            Fabricate(:issue_notification, issue: issue, user: current_user)
          end

          context "for an html request" do
            it "destroys the requested issue's notifications" do
              expect do
                delete :bulk_destroy, params: { issue_id: issue.to_param }
              end.to change(IssueNotification, :count).by(-1)
            end

            it "redirects to the issue" do
              delete :bulk_destroy, params: { issue_id: issue.to_param }
              expect(response).to redirect_to(issue)
            end
          end

          context "for an ajax request" do
            it "destroys the requested issue's notifications" do
              expect do
                delete :bulk_destroy, params: { issue_id: issue.to_param },
                                      xhr: true
              end.to change(IssueNotification, :count).by(-1)
            end

            it "renders :destroy" do
              delete :bulk_destroy, params: { issue_id: issue.to_param },
                                    xhr: true
              expect(response).to be_successful
            end
          end
        end

        context "when no issue_notifications" do
          before { Fabricate(:issue_notification, issue: issue) }

          it "doesn't destroy the requested issue's notifications" do
            expect do
              delete :bulk_destroy, params: { issue_id: issue.to_param }
            end.not_to change(IssueNotification, :count)
          end

          it "redirects to the issue" do
            delete :bulk_destroy, params: { issue_id: issue.to_param }
            expect(response).to redirect_to(issue)
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when they have notifications for the requested issue" do
          before do
            Fabricate(:issue_notification, issue: issue)
            Fabricate(:issue_notification, issue: issue, user: current_user)
          end

          it "destroys the requested issue's notifications" do
            expect do
              delete :bulk_destroy, params: { issue_id: issue.to_param }
            end.to change(IssueNotification, :count).by(-1)
          end

          it "redirects to the issue" do
            delete :bulk_destroy, params: { issue_id: issue.to_param }
            expect(response).to redirect_to(issue)
          end
        end

        context "when no issue_notifications" do
          before { Fabricate(:issue_notification, issue: issue) }

          it "doesn't destroy any issue_notifications" do
            expect do
              delete :bulk_destroy, params: { issue_id: issue.to_param }
            end.not_to change(IssueNotification, :count)
          end

          it "redirects to the issue" do
            delete :bulk_destroy, params: { issue_id: issue.to_param }
            expect(response).to redirect_to(issue)
          end
        end

        context "when requested issue is invisible" do
          let(:project) { Fabricate(:invisible_project) }
          let(:issue) { Fabricate(:issue, project: project) }

          before do
            Fabricate(:issue_notification, issue: issue, user: current_user)
          end

          it "doesn't destroy any issue_notifications" do
            expect do
              delete :bulk_destroy, params: { issue_id: issue.to_param }
            end.not_to change(TaskNotification, :count)
          end

          it "should be unauthorized" do
            delete :bulk_destroy, params: { issue_id: issue.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end
end
