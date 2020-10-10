# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssuesController, type: :controller do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue_type) { Fabricate(:issue_type) }
  let(:user) { Fabricate(:user_reporter) }
  let(:admin) { Fabricate(:user_admin) }

  let(:valid_attributes) do
    { issue_type_id: issue_type.id, summary: "Summary",
      description: "Description" }
  end

  let(:invalid_attributes) { { summary: "" } }

  describe "GET #index" do
    let(:category) { Fabricate(:category) }
    let(:project) { Fabricate(:project, category: category) }

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type.downcase}")) }

        context "when only category" do
          it "returns a success response" do
            _issue = Fabricate(:issue, project: project)
            get :index, params: { category_id: category.to_param }
            expect(response).to be_successful
          end
        end

        context "when category and project" do
          it "returns a success response" do
            _issue = Fabricate(:issue, project: project)
            get :index, params: { category_id: category.to_param,
                                  project_id: project.to_param }
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "GET #show" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type.downcase}")) }

        context "when only category" do
          it "returns a success response" do
            issue = Fabricate(:issue, project: project)
            get :show, params: { category_id: category.to_param,
                                 id: issue.to_param }
            expect(response).to be_successful
          end
        end

        context "when category and project" do
          it "returns a success response" do
            issue = Fabricate(:issue, project: project)
            get :show, params: { category_id: category.to_param,
                                 project_id: project.to_param,
                                 id: issue.to_param }
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "GET #new" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type.downcase}")) }

        context "when an IssueType and a User" do
          before do
            Fabricate(:issue_type)
            Fabricate(:user_reporter)
          end

          it "returns a success response" do
            get :new, params: { category_id: category.to_param,
                                project_id: project.to_param }
            expect(response).to be_successful
          end
        end

        context "when no IssueTypes" do
          before { Fabricate(:user_reporter) }

          it "redirects to project" do
            get :new, params: { category_id: category.to_param,
                                project_id: project.to_param }
            expect(response)
              .to redirect_to(category_project_url(category, project))
          end
        end
      end
    end
  end

  describe "GET #edit" do
    context "for an admin" do
      before { login(admin) }

      context "for their own Issue" do
        it "returns a success response" do
          issue = Fabricate(:issue, project: project, user: admin)
          get :edit, params: { category_id: category.to_param,
                               project_id: project.to_param,
                               id: issue.to_param }
          expect(response).to be_successful
        end
      end

      context "for someone else's Issue" do
        it "returns a success response" do
          issue = Fabricate(:issue, project: project)
          get :edit, params: { category_id: category.to_param,
                               project_id: project.to_param,
                               id: issue.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "for their own Issue" do
          it "returns a success response" do
            issue = Fabricate(:issue, project: project, user: current_user)
            get :edit, params: { category_id: category.to_param,
                                 project_id: project.to_param,
                                 id: issue.to_param }
            expect(response).to be_successful
          end
        end

        context "for someone else's Issue" do
          it "should be unauthorized" do
            issue = Fabricate(:issue, project: project)
            get :edit, params: { category_id: category.to_param,
                                 project_id: project.to_param,
                                 id: issue.to_param }
            expect_to_be_unauthorized(response)
          end
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
          it "creates a new Issue" do
            expect do
              post :create, params: { category_id: category.to_param,
                                      project_id: project.to_param,
                                      issue: valid_attributes }
            end.to change(current_user.issues, :count).by(1)
          end

          it "redirects to the created issue" do
            post :create, params: { category_id: category.to_param,
                                    project_id: project.to_param,
                                    issue: valid_attributes }
            url = category_project_issue_path(category, project, Issue.last)
            expect(response).to redirect_to(url)
          end
        end

        context "with invalid params" do
          it "returns a success response ('new' template)" do
            post :create, params: { category_id: category.to_param,
                                    project_id: project.to_param,
                                    issue: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "PUT #update" do
    let(:new_attributes) { { summary: "New Summary" } }

    context "for an admin" do
      before { login(admin) }

      context "for their own Issue" do
        context "with valid params" do
          it "updates the requested issue" do
            issue = Fabricate(:issue, project: project, user: admin)

            expect do
              put :update, params: { category_id: category.to_param,
                                     project_id: project.to_param,
                                     id: issue.to_param,
                                     issue: new_attributes }
              issue.reload
            end.to change(issue, :summary).to("New Summary")
          end

          it "redirects to the issue" do
            issue = Fabricate(:issue, project: project, user: admin)
            url = category_project_issue_url(category, project, issue)

            put :update, params: { category_id: category.to_param,
                                   project_id: project.to_param,
                                   id: issue.to_param,
                                   issue: new_attributes }
            expect(response).to redirect_to(url)
          end
        end

        context "with invalid params" do
          it "returns a success response ('edit' template)" do
            issue = Fabricate(:issue, project: project, user: admin)
            put :update, params: { category_id: category.to_param,
                                   project_id: project.to_param,
                                   id: issue.to_param,
                                   issue: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end

      context "for someone else's Issue" do
        context "with valid params" do
          it "updates the requested issue" do
            issue = Fabricate(:issue, project: project)

            expect do
              put :update, params: { category_id: category.to_param,
                                     project_id: project.to_param,
                                     id: issue.to_param,
                                     issue: new_attributes }
              issue.reload
            end.to change(issue, :summary).to("New Summary")
          end

          it "redirects to the issue" do
            issue = Fabricate(:issue, project: project)
            url = category_project_issue_url(category, project, issue)

            put :update, params: { category_id: category.to_param,
                                   project_id: project.to_param,
                                   id: issue.to_param,
                                   issue: new_attributes }
            expect(response).to redirect_to(url)
          end
        end

        context "with invalid params" do
          it "returns a success response ('edit' template)" do
            issue = Fabricate(:issue, project: project)
            put :update, params: { category_id: category.to_param,
                                   project_id: project.to_param,
                                   id: issue.to_param,
                                   issue: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "for their own Issue" do
          context "with valid params" do
            it "updates the requested issue" do
              issue = Fabricate(:issue, project: project, user: current_user)

              expect do
                put :update, params: { category_id: category.to_param,
                                       project_id: project.to_param,
                                       id: issue.to_param,
                                       issue: new_attributes }
                issue.reload
              end.to change(issue, :summary).to("New Summary")
            end

            it "redirects to the issue" do
              issue = Fabricate(:issue, project: project, user: current_user)
              url = category_project_issue_url(category, project, issue)

              put :update, params: { category_id: category.to_param,
                                     project_id: project.to_param,
                                     id: issue.to_param,
                                     issue: new_attributes }
              expect(response).to redirect_to(url)
            end
          end

          context "with invalid params" do
            it "returns a success response ('edit' template)" do
              issue = Fabricate(:issue, project: project, user: current_user)
              put :update, params: { category_id: category.to_param,
                                     project_id: project.to_param,
                                     id: issue.to_param,
                                     issue: invalid_attributes }
              expect(response).to be_successful
            end
          end
        end

        context "for someone else's Issue" do
          it "should be unauthorized" do
            issue = Fabricate(:issue, project: project)
            put :update, params: { category_id: category.to_param,
                                   project_id: project.to_param,
                                   id: issue.to_param,
                                   issue: new_attributes }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "for an admin" do
      before { login(admin) }

      it "destroys the requested issue" do
        issue = Fabricate(:issue, project: project)
        expect do
          delete :destroy, params: { category_id: category.to_param,
                                     project_id: project.to_param,
                                     id: issue.to_param }
        end.to change(Issue, :count).by(-1)
      end

      it "redirects to the issues list" do
        issue = Fabricate(:issue, project: project)
        delete :destroy, params: { category_id: category.to_param,
                                   project_id: project.to_param,
                                   id: issue.to_param }
        expect(response).to redirect_to(category_project_url(category, project))
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "should be unauthorized" do
          issue = Fabricate(:issue, project: project, user: current_user)
          delete :destroy, params: { category_id: category.to_param,
                                     project_id: project.to_param,
                                     id: issue.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "PUT #open" do
    context "for an admin" do
      before { login(admin) }

      context "with valid params" do
        it "updates the requested issue" do
          issue = Fabricate(:closed_issue, project: project)

          expect do
            put :open, params: { id: issue.to_param }
            issue.reload
          end.to change(issue, :closed).to(false)
        end

        it "redirects to the issue" do
          issue = Fabricate(:closed_issue, project: project)
          url = category_project_issue_url(category, project, issue)
          put :open, params: { id: issue.to_param }
          expect(response).to redirect_to(url)
        end
      end

      context "with invalid params" do
        let(:issue) { Fabricate(:closed_issue, project: project) }

        before { issue.user.destroy }

        it "doesn't update the requested issue" do
          expect do
            put :open, params: { id: issue.to_param }
            issue.reload
          end.not_to change(issue, :closed)
        end

        it "returns a success response ('edit' template)" do
          put :open, params: { id: issue.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "should be unauthorized" do
          issue = Fabricate(:closed_issue, project: project, user: current_user)
          put :open, params: { id: issue.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "PUT #close" do
    context "for an admin" do
      before { login(admin) }

      context "with valid params" do
        it "updates the requested issue" do
          issue = Fabricate(:open_issue, project: project)

          expect do
            put :close, params: { id: issue.to_param }
            issue.reload
          end.to change(issue, :closed).to(true)
        end

        it "redirects to the issue" do
          issue = Fabricate(:open_issue, project: project)
          url = category_project_issue_url(category, project, issue)

          put :close, params: { id: issue.to_param }
          expect(response).to redirect_to(url)
        end
      end

      context "with invalid params" do
        let(:issue) { Fabricate(:closed_issue, project: project) }

        before { issue.user.destroy }

        it "returns a success response (i.e. to display the 'edit' template)" do
          put :close, params: { id: issue.to_param }
          expect(response).to be_successful
        end

        it "doesn't update the requested issue" do
          expect do
            put :close, params: { id: issue.to_param }
            issue.reload
          end.not_to change(issue, :closed)
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "should be unauthorized" do
          issue = Fabricate(:open_issue, project: project, user: current_user)
          put :close, params: { id: issue.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
