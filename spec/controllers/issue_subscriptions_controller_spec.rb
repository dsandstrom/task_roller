# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueSubscriptionsController, type: :controller do
  let(:issue) { Fabricate(:issue) }

  describe "GET #new" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { login(current_user) }

        it "returns a success response" do
          get :new, params: { issue_id: issue.to_param }
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
          it "creates a new IssueSubscription" do
            expect do
              post :create, params: { issue_id: issue.to_param }
            end.to change(current_user.issue_subscriptions, :count).by(1)
          end

          it "redirects to the requested issue" do
            post :create, params: { issue_id: issue.to_param }
            expect(response).to redirect_to(issue)
          end
        end

        context "with invalid params" do
          before do
            Fabricate(:issue_subscription, issue: issue, user: current_user)
          end

          it "doesn't create a new IssueSubscription" do
            expect do
              post :create, params: { issue_id: issue.to_param }
            end.not_to change(IssueSubscription, :count)
          end

          it "renders new" do
            post :create, params: { issue_id: issue.to_param }
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

        context "when their issue_subscription" do
          it "destroys the requested issue_subscription" do
            issue_subscription =
              Fabricate(:issue_subscription, issue: issue, user: current_user)
            expect do
              delete :destroy, params: { issue_id: issue.to_param,
                                         id: issue_subscription.to_param }
            end.to change(current_user.issue_subscriptions, :count).by(-1)
          end

          it "redirects to the issue_subscriptions list" do
            issue_subscription =
              Fabricate(:issue_subscription, issue: issue, user: current_user)
            delete :destroy, params: { issue_id: issue.to_param,
                                       id: issue_subscription.to_param }
            expect(response).to redirect_to(issue)
          end
        end

        context "when someone else's issue_subscription" do
          it "doesn't destroys the requested issue_subscription" do
            issue_subscription = Fabricate(:issue_subscription, issue: issue)
            expect do
              delete :destroy, params: { issue_id: issue.to_param,
                                         id: issue_subscription.to_param }
            end.not_to change(IssueSubscription, :count)
          end

          it "should be unauthorized" do
            issue_subscription = Fabricate(:issue_subscription, issue: issue)
            delete :destroy, params: { issue_id: issue.to_param,
                                       id: issue_subscription.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end
end
