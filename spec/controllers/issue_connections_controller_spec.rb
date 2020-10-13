# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueConnectionsController, type: :controller do
  let(:project) { Fabricate(:project) }
  let(:source_issue) { Fabricate(:issue, project: project) }
  let(:target_issue) { Fabricate(:issue, project: project) }
  let(:valid_attributes) { { target_id: target_issue.to_param } }
  let(:invalid_attributes) { { target_id: "" } }
  let(:path) do
    category_project_issue_path(source_issue.category,
                                source_issue.project, source_issue)
  end

  describe "GET #new" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "returns a success response" do
          get :new, params: { source_id: source_issue.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

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

        before { login(current_user) }

        context "with valid params" do
          it "creates a new IssueConnection for the source" do
            expect do
              post :create, params: { source_id: source_issue.to_param,
                                      issue_connection: valid_attributes }
              source_issue.reload
            end.to change(source_issue, :source_issue_connection).from(nil)
          end

          it "creates a new IssueConnection for the target" do
            expect do
              post :create, params: { source_id: source_issue.to_param,
                                      issue_connection: valid_attributes }
              target_issue.reload
            end.to change(target_issue.target_issue_connections, :count).by(1)
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
            expect(response).to redirect_to(path)
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

        before { login(current_user) }

        it "doesn't create a new IssueConnection" do
          expect do
            post :create, params: { source_id: source_issue.to_param,
                                    issue_connection: valid_attributes }
          end.not_to change(IssueConnection, :count)
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
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "destroys the requested issue_connection" do
          issue_connection = Fabricate(:issue_connection, source: source_issue)
          expect do
            delete :destroy, params: { id: issue_connection.to_param }
          end.to change(IssueConnection, :count).by(-1)
        end

        it "redirects to the issue_connections list" do
          issue_connection = Fabricate(:issue_connection, source: source_issue)
          delete :destroy, params: { id: issue_connection.to_param }
          expect(response).to redirect_to(path)
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "doesn't destroy the requested issue_connection" do
          issue_connection = Fabricate(:issue_connection, source: source_issue)
          expect do
            delete :destroy, params: { id: issue_connection.to_param }
          end.not_to change(IssueConnection, :count)
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
