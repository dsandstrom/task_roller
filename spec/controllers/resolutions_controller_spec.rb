# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResolutionsController, type: :controller do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue) { Fabricate(:issue, project: project) }
  let(:admin) { Fabricate(:user_admin) }

  describe "GET #index" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type.downcase}")) }

        it "returns a success response" do
          _resolution = Fabricate(:resolution, issue: issue)
          get :index, params: { issue_id: issue.to_param }
          expect(response).to be_successful
        end
      end
    end
  end

  describe "GET #new" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { login(current_user) }

        context "when their issue" do
          let(:issue) do
            Fabricate(:issue, project: project, user: current_user)
          end

          it "returns a success response" do
            get :new, params: { issue_id: issue.to_param }
            expect(response).to be_successful
          end
        end

        context "when someone else's issue" do
          let(:issue) { Fabricate(:issue, project: project) }

          it "should be unauthorized" do
            get :new, params: { issue_id: issue.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "PUT #approve" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { login(current_user) }

        context "when their issue" do
          let(:issue) do
            Fabricate(:issue, project: project, user: current_user)
          end

          context "with valid params" do
            it "creates an approved resolution" do
              expect do
                post :approve, params: { issue_id: issue.to_param }
              end.to change(issue.resolutions.approved, :count).by(1)
            end

            it "redirects to the resolution" do
              post :approve, params: { issue_id: issue.to_param }
              url = category_project_issue_path(category, project, issue)
              expect(response).to redirect_to(url)
            end
          end

          context "with invalid params" do
            it "returns a success response ('edit' template)" do
              issue.update_column :summary, nil
              post :approve, params: { issue_id: issue.to_param }
              expect(response).to be_successful
            end
          end
        end

        context "when someone else's issue" do
          let(:issue) { Fabricate(:issue, project: project) }

          it "doesn't create a Resolution" do
            expect do
              post :approve, params: { issue_id: issue.to_param }
            end.not_to change(Resolution, :count)
          end

          it "should be unauthorized" do
            post :approve, params: { issue_id: issue.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "PUT #disapprove" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { login(current_user) }

        context "when their issue" do
          let(:issue) do
            Fabricate(:issue, project: project, user: current_user)
          end

          context "with valid params" do
            it "creates an disapproved resolution" do
              expect do
                post :disapprove, params: { issue_id: issue.to_param }
              end.to change(issue.resolutions.disapproved, :count).by(1)
            end

            it "redirects to the resolution" do
              post :disapprove, params: { issue_id: issue.to_param }
              url = category_project_issue_path(category, project, issue)
              expect(response).to redirect_to(url)
            end
          end

          context "with invalid params" do
            it "returns a success response ('edit' template)" do
              issue.update_column :summary, nil
              post :disapprove, params: { issue_id: issue.to_param }
              expect(response).to be_successful
            end
          end
        end

        context "when someone else's issue" do
          let(:issue) { Fabricate(:issue, project: project) }

          it "doesn't create a Resolution" do
            expect do
              post :disapprove, params: { issue_id: issue.to_param }
            end.not_to change(Resolution, :count)
          end

          it "should be unauthorized" do
            post :disapprove, params: { issue_id: issue.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "for an admin" do
      before { login(admin) }

      it "destroys the requested resolution" do
        resolution = Fabricate(:resolution, issue: issue)
        expect do
          delete :destroy, params: { issue_id: issue.to_param,
                                     id: resolution.to_param }
        end.to change(Resolution, :count).by(-1)
      end

      it "redirects to the resolutions list" do
        resolution = Fabricate(:resolution, issue: issue)
        delete :destroy, params: { issue_id: issue.to_param,
                                   id: resolution.to_param }
        expect(response)
          .to redirect_to(category_project_issue_path(category, project, issue))
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "doesn't destroy the requested resolution" do
          resolution = Fabricate(:resolution, issue: issue)
          expect do
            delete :destroy, params: { issue_id: issue.to_param,
                                       id: resolution.to_param }
          end.not_to change(Resolution, :count)
        end

        it "should be unauthorized" do
          resolution = Fabricate(:resolution, issue: issue)
          delete :destroy, params: { issue_id: issue.to_param,
                                     id: resolution.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
