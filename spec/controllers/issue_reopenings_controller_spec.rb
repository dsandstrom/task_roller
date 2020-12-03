# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueReopeningsController, type: :controller do
  let(:issue) { Fabricate(:closed_issue) }

  describe "GET #new" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "returns a success response" do
          get :new, params: { issue_id: issue.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "should be unauthorized" do
          get :new, params: { issue_id: issue.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "POST #create" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "with valid params" do
          it "creates a new IssueReopening for the issue" do
            expect do
              post :create, params: { issue_id: issue.to_param }
              issue.reload
            end.to change(issue.reopenings, :count).by(1)
          end

          it "creates a new IssueSubscription for the current_user" do
            expect do
              post :create, params: { issue_id: issue.to_param }
              issue.reload
            end.to change(current_user.issue_subscriptions, :count).by(1)
          end

          it "opens the issue" do
            expect do
              post :create, params: { issue_id: issue.to_param }
              issue.reload
            end.to change(issue, :closed).to(false)
          end

          it "redirects to the created issue_reopening" do
            post :create, params: { issue_id: issue.to_param }
            expect(response).to redirect_to(issue)
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "doesn't create a new IssueReopening" do
          expect do
            post :create, params: { issue_id: issue.to_param }
          end.not_to change(IssueReopening, :count)
        end

        it "doesn't create a new IssueSubscription" do
          expect do
            post :create, params: { issue_id: issue.to_param }
          end.not_to change(IssueSubscription, :count)
        end

        it "doesn't open the issue" do
          expect do
            post :create, params: { issue_id: issue.to_param }
            issue.reload
          end.not_to change(issue, :closed).from(true)
        end

        it "should be unauthorized" do
          post :create, params: { issue_id: issue.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:issue) { Fabricate(:open_issue) }

    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "destroys the requested issue_reopening" do
          issue_reopening = Fabricate(:issue_reopening, issue: issue)
          expect do
            delete :destroy, params: { issue_id: issue.to_param,
                                       id: issue_reopening.to_param }
          end.to change(IssueReopening, :count).by(-1)
        end

        it "doesn't change the requested issue_reopening's issue" do
          issue_reopening = Fabricate(:issue_reopening, issue: issue)
          expect do
            delete :destroy, params: { issue_id: issue.to_param,
                                       id: issue_reopening.to_param }
          end.not_to change(issue, :closed)
        end

        it "redirects to the issue_reopenings list" do
          issue_reopening = Fabricate(:issue_reopening, issue: issue)
          delete :destroy, params: { issue_id: issue.to_param,
                                     id: issue_reopening.to_param }
          expect(response).to redirect_to(issue)
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "doesn't destroy the requested issue_reopening" do
          issue_reopening = Fabricate(:issue_reopening, issue: issue)
          expect do
            delete :destroy, params: { issue_id: issue.to_param,
                                       id: issue_reopening.to_param }
          end.not_to change(IssueReopening, :count)
        end

        it "doesn't change the requested issue_reopening's issue" do
          issue_reopening = Fabricate(:issue_reopening, issue: issue)
          expect do
            delete :destroy, params: { issue_id: issue.to_param,
                                       id: issue_reopening.to_param }
          end.not_to change(issue, :closed)
        end

        it "should be unauthorized" do
          issue_reopening = Fabricate(:issue_reopening, issue: issue)
          delete :destroy, params: { issue_id: issue.to_param,
                                     id: issue_reopening.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
