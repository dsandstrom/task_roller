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
end
