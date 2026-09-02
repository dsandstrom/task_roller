require "rails_helper"

RSpec.describe IssueTypeMigrationsController, type: :controller do
  describe "GET #new" do
    let(:issue_type) { Fabricate(:issue_type) }

    before { Fabricate(:issue_type) }

    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        it "returns a success response" do
          get :new, params: { issue_type_id: issue_type.id }

          expect(response).to be_successful
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        it "should be unauthorized" do
          get :new, params: { issue_type_id: issue_type.id }

          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "POST #create" do
    let(:issue_type) { Fabricate(:issue_type) }
    let(:new_issue_type) { Fabricate(:issue_type) }

    let(:valid_params) { { new_issue_type_id: new_issue_type.to_param } }
    let(:invalid_params) { { new_issue_type_id: "" } }

    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when current issue_type has an issue" do
          let!(:issue) { Fabricate(:issue, issue_type: issue_type) }

          context "when valid params" do
            it "updates the issue's issue_type" do
              expect do
                post :create, params: { issue_type_id: issue_type.id,
                                        issue_type: valid_params }
                issue.reload
              end.to change(issue, :issue_type_id).to(new_issue_type.id)
            end

            it "redirects to issue_types index" do
              post :create, params: { issue_type_id: issue_type.id,
                                      issue_type: valid_params }

              expect(response).to redirect_to(issue_types_path)
            end
          end

          context "when invalid params" do
            it "doesn't update the issue" do
              expect do
                post :create, params: { issue_type_id: issue_type.id,
                                        issue_type: invalid_params }
                issue.reload
              end.not_to change(issue, :issue_type_id)
            end

            it "returns a success response" do
              post :create, params: { issue_type_id: issue_type.id,
                                      issue_type: invalid_params }

              expect(response).to be_successful
            end
          end
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let!(:issue) { Fabricate(:issue, issue_type: issue_type) }

        before { sign_in(current_user) }

        it "doesn't update the issue" do
          expect do
            post :create, params: { issue_type_id: issue_type.id,
                                    issue_type: valid_params }
            issue.reload
          end.not_to change(issue, :issue_type_id)
        end

        it "should be unauthorized" do
          post :create, params: { issue_type_id: issue_type.id,
                                  issue_type: valid_params }

          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
