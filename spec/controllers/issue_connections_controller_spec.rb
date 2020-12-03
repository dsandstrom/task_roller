# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueConnectionsController, type: :controller do
  let(:source_issue) { Fabricate(:issue) }
  let(:target_issue) { Fabricate(:issue, project: source_issue.project) }
  let(:valid_attributes) { { target_id: target_issue.to_param } }
  let(:invalid_attributes) { { target_id: "" } }

  describe "GET #new" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "returns a success response" do
          get :new, params: { source_id: source_issue.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "should be unauthorized" do
          get :new, params: { source_id: source_issue.to_param }
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
          it "creates a new IssueConnection for the source" do
            expect do
              post :create, params: { source_id: source_issue.to_param,
                                      issue_connection: valid_attributes }
              source_issue.reload
            end.to change(source_issue, :source_connection).from(nil)
          end

          it "creates a new IssueConnection for the target" do
            expect do
              post :create, params: { source_id: source_issue.to_param,
                                      issue_connection: valid_attributes }
              target_issue.reload
            end.to change(target_issue.target_connections, :count).by(1)
          end

          it "creates 2 IssueSubscriptions for the current_user" do
            expect do
              post :create, params: { source_id: source_issue.to_param,
                                      issue_connection: valid_attributes }
              target_issue.reload
            end.to change(current_user.issue_subscriptions, :count).by(2)
          end

          it "creates a new IssueSubscription for the source user" do
            expect do
              post :create, params: { source_id: source_issue.to_param,
                                      issue_connection: valid_attributes }
              target_issue.reload
            end.to change(source_issue.user.issue_subscriptions, :count).by(1)
          end

          it "creates 2 IssueSubscriptions for the target issue" do
            expect do
              post :create, params: { source_id: source_issue.to_param,
                                      issue_connection: valid_attributes }
              target_issue.reload
            end.to change(target_issue.issue_subscriptions, :count).by(2)
          end

          it "closes the source issue" do
            expect do
              post :create, params: { source_id: source_issue.to_param,
                                      issue_connection: valid_attributes }
              source_issue.reload
            end.to change(source_issue, :closed).to(true)
          end

          it "redirects to the created issue_connection" do
            post :create, params: { source_id: source_issue.to_param,
                                    issue_connection: valid_attributes }
            expect(response).to redirect_to(source_issue)
          end
        end

        context "with invalid params" do
          it "doesn't create a new IssueConnection" do
            expect do
              post :create, params: { source_id: source_issue.to_param,
                                      issue_connection: invalid_attributes }
              source_issue.reload
            end.not_to change(IssueConnection, :count)
          end

          it "returns a success response ('new' template)" do
            post :create, params: { source_id: source_issue.to_param,
                                    issue_connection: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "doesn't create a new IssueConnection" do
          expect do
            post :create, params: { source_id: source_issue.to_param,
                                    issue_connection: valid_attributes }
          end.not_to change(IssueConnection, :count)
        end

        it "doesn't create a new IssueSubscription" do
          expect do
            post :create, params: { source_id: source_issue.to_param,
                                    issue_connection: valid_attributes }
          end.not_to change(IssueSubscription, :count)
        end

        it "doesn't close the source issue" do
          expect do
            post :create, params: { source_id: source_issue.to_param,
                                    issue_connection: valid_attributes }
            source_issue.reload
          end.not_to change(source_issue, :closed).from(false)
        end

        it "should be unauthorized" do
          post :create, params: { source_id: source_issue.to_param,
                                  issue_connection: valid_attributes }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      source_issue.close
      target_issue.close
    end

    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "destroys the requested issue_connection" do
          issue_connection = Fabricate(:issue_connection, source: source_issue)
          expect do
            delete :destroy, params: { id: issue_connection.to_param }
          end.to change(IssueConnection, :count).by(-1)
        end

        it "reopens the source issue" do
          issue_connection = Fabricate(:issue_connection, source: source_issue)
          expect do
            delete :destroy, params: { id: issue_connection.to_param }
            source_issue.reload
          end.to change(source_issue, :closed).to(false)
        end

        it "creates a reopening for the source_issue" do
          issue_connection = Fabricate(:issue_connection, source: source_issue)
          expect do
            delete :destroy, params: { id: issue_connection.to_param }
          end.to change(source_issue.reopenings, :count).by(1)
        end

        it "doesn't change the target issue" do
          issue_connection = Fabricate(:issue_connection, source: source_issue,
                                                          target: target_issue)
          expect do
            delete :destroy, params: { id: issue_connection.to_param }
            target_issue.reload
          end.not_to change(target_issue, :closed)
        end

        it "redirects to the issue_connections list" do
          issue_connection = Fabricate(:issue_connection, source: source_issue)
          delete :destroy, params: { id: issue_connection.to_param }
          expect(response).to redirect_to(source_issue)
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "doesn't destroy the requested issue_connection" do
          issue_connection = Fabricate(:issue_connection, source: source_issue)
          expect do
            delete :destroy, params: { id: issue_connection.to_param }
          end.not_to change(IssueConnection, :count)
        end

        it "doesn't change the source issue" do
          issue_connection = Fabricate(:issue_connection, source: source_issue)
          expect do
            delete :destroy, params: { id: issue_connection.to_param }
            source_issue.reload
          end.not_to change(source_issue, :closed)
        end

        it "should be unauthorized" do
          issue_connection = Fabricate(:issue_connection, source: source_issue)
          delete :destroy, params: { id: issue_connection.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
