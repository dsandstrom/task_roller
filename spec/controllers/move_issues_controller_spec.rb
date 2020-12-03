# frozen_string_literal: true

require "rails_helper"

RSpec.describe MoveIssuesController, type: :controller do
  let(:new_project) { Fabricate(:project) }

  let(:valid_attributes) { { project_id: new_project.to_param } }
  let(:invalid_attributes) { { project_id: "" } }

  describe "GET #edit" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "returns a success response" do
          issue = Fabricate(:issue)
          get :edit, params: { issue_id: issue.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "should be unauthorized" do
          issue = Fabricate(:issue)
          get :edit, params: { issue_id: issue.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "PUT #update" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        context "with valid params" do
          it "updates the requested issue" do
            issue = Fabricate(:issue)
            expect do
              put :update, params: { issue_id: issue.to_param,
                                     issue: valid_attributes }
              issue.reload
            end.to change(issue, :project_id).to(new_project.id)
          end

          it "redirects to the issue" do
            issue = Fabricate(:issue)
            put :update, params: { issue_id: issue.to_param,
                                   issue: valid_attributes }
            expect(response).to redirect_to(issue)
          end
        end

        context "with invalid params" do
          it "doesn't update the requested issue" do
            issue = Fabricate(:issue)
            expect do
              put :update, params: { issue_id: issue.to_param,
                                     issue: invalid_attributes }
              issue.reload
            end.not_to change(issue, :project_id)
          end

          it "redirects to edit" do
            issue = Fabricate(:issue)
            put :update, params: { issue_id: issue.to_param,
                                   issue: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        it "redirects to unauthorized" do
          issue = Fabricate(:issue)
          put :update, params: { issue_id: issue.to_param,
                                 issue: valid_attributes }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
