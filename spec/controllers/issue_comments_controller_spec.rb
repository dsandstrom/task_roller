# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueCommentsController, type: :controller do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue) { Fabricate(:issue, project: project) }
  let(:admin) { Fabricate(:user_admin) }

  let(:valid_attributes) { { body: "Body" } }
  let(:invalid_attributes) { { body: "" } }

  describe "GET #new" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type.downcase}")) }

        it "returns a success response" do
          get :new, params: { issue_id: issue.to_param }
          expect(response).to be_successful
        end
      end
    end
  end

  describe "GET #edit" do
    context "for an admin" do
      before { login(admin) }

      context "for their own IssueComment" do
        it "returns a success response" do
          issue_comment = Fabricate(:issue_comment, issue: issue, user: admin)
          get :edit, params: { issue_id: issue.to_param,
                               id: issue_comment.to_param }
          expect(response).to be_successful
        end
      end

      context "for someone else's IssueComment" do
        it "returns a success response" do
          issue_comment = Fabricate(:issue_comment, issue: issue)
          get :edit, params: { issue_id: issue.to_param,
                               id: issue_comment.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "for their own IssueComment" do
          it "returns a success response" do
            issue_comment =
              Fabricate(:issue_comment, issue: issue, user: current_user)
            get :edit, params: { issue_id: issue.to_param,
                                 id: issue_comment.to_param }
            expect(response).to be_successful
          end
        end

        context "for someone else's IssueComment" do
          it "should be unauthorized" do
            issue_comment = Fabricate(:issue_comment, issue: issue)
            get :edit, params: { issue_id: issue.to_param,
                                 id: issue_comment.to_param }
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
          it "creates a new IssueComment" do
            expect do
              post :create, params: { issue_id: issue.to_param,
                                      issue_comment: valid_attributes }
            end.to change(current_user.issue_comments, :count).by(1)
          end

          it "redirects to the created issue_comment" do
            post :create, params: { issue_id: issue.to_param,
                                    issue_comment: valid_attributes }
            anchor = "comment-#{IssueComment.last.id}"
            url = issue_url(issue, anchor: anchor)
            expect(response).to redirect_to(url)
          end

          context "when not subscribed to issue" do
            it "creates a new IssueSubscription" do
              expect do
                post :create, params: { issue_id: issue.to_param,
                                        issue_comment: valid_attributes }
              end.to change(current_user.issue_subscriptions, :count).by(1)
            end
          end

          context "when already subscribed to issue" do
            before do
              Fabricate(:issue_subscription, issue: issue, user: current_user)
            end

            it "doesn't create a new IssueSubscription" do
              expect do
                post :create, params: { issue_id: issue.to_param,
                                        issue_comment: valid_attributes }
              end.not_to change(IssueSubscription, :count)
            end
          end
        end

        context "with invalid params" do
          it "returns a success response ('new' template)" do
            post :create, params: { issue_id: issue.to_param,
                                    issue_comment: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "PUT #update" do
    let(:new_attributes) { { body: "New body" } }

    context "for an admin" do
      before { login(admin) }

      context "for their own IssueComment" do
        context "with valid params" do
          it "updates the requested issue_comment" do
            issue_comment = Fabricate(:issue_comment, issue: issue, user: admin)
            expect do
              put :update, params: { issue_id: issue.to_param,
                                     id: issue_comment.to_param,
                                     issue_comment: new_attributes }
              issue_comment.reload
            end.to change(issue_comment, :body).to("New body")
          end

          it "redirects to the issue_comment" do
            issue_comment = Fabricate(:issue_comment, issue: issue, user: admin)
            url = issue_url(issue, anchor: "comment-#{issue_comment.id}")
            put :update, params: { issue_id: issue.to_param,
                                   id: issue_comment.to_param,
                                   issue_comment: new_attributes }
            expect(response).to redirect_to(url)
          end
        end

        context "with invalid params" do
          it "returns a success response ('edit' template)" do
            issue_comment = Fabricate(:issue_comment, issue: issue, user: admin)
            put :update, params: { issue_id: issue.to_param,
                                   id: issue_comment.to_param,
                                   issue_comment: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end

      context "for someone else's IssueComment" do
        context "with valid params" do
          let(:new_attributes) { { body: "New body" } }

          it "updates the requested issue_comment" do
            issue_comment = Fabricate(:issue_comment, issue: issue)
            expect do
              put :update, params: { issue_id: issue.to_param,
                                     id: issue_comment.to_param,
                                     issue_comment: new_attributes }
              issue_comment.reload
            end.to change(issue_comment, :body).to("New body")
          end

          it "redirects to the issue_comment" do
            issue_comment = Fabricate(:issue_comment, issue: issue)
            url = issue_url(issue, anchor: "comment-#{issue_comment.id}")
            put :update, params: { issue_id: issue.to_param,
                                   id: issue_comment.to_param,
                                   issue_comment: new_attributes }
            expect(response).to redirect_to(url)
          end
        end

        context "with invalid params" do
          it "returns a success response ('edit' template)" do
            issue_comment = Fabricate(:issue_comment, issue: issue)
            put :update, params: { issue_id: issue.to_param,
                                   id: issue_comment.to_param,
                                   issue_comment: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "for their own IssueComment" do
          context "with valid params" do
            it "updates the requested issue_comment" do
              issue_comment =
                Fabricate(:issue_comment, issue: issue, user: current_user)
              expect do
                put :update, params: { issue_id: issue.to_param,
                                       id: issue_comment.to_param,
                                       issue_comment: new_attributes }
                issue_comment.reload
              end.to change(issue_comment, :body).to("New body")
            end

            it "redirects to the issue_comment" do
              issue_comment = Fabricate(:issue_comment, issue: issue,
                                                        user: current_user)
              anchor = "comment-#{issue_comment.id}"
              url = issue_url(issue, anchor: anchor)
              put :update, params: { issue_id: issue.to_param,
                                     id: issue_comment.to_param,
                                     issue_comment: new_attributes }
              expect(response).to redirect_to(url)
            end
          end

          context "with invalid params" do
            it "returns a success response ('edit' template)" do
              issue_comment =
                Fabricate(:issue_comment, issue: issue, user: current_user)
              put :update, params: { issue_id: issue.to_param,
                                     id: issue_comment.to_param,
                                     issue_comment: invalid_attributes }
              expect(response).to be_successful
            end
          end
        end

        context "for someone else's IssueComment" do
          it "doesn't update the requested issue_comment" do
            issue_comment = Fabricate(:issue_comment, issue: issue)
            expect do
              put :update, params: { issue_id: issue.to_param,
                                     id: issue_comment.to_param,
                                     issue_comment: new_attributes }
              issue_comment.reload
            end.not_to change(issue_comment, :body)
          end

          it "should be unauthorized" do
            issue_comment = Fabricate(:issue_comment, issue: issue)
            put :update, params: { issue_id: issue.to_param,
                                   id: issue_comment.to_param,
                                   issue_comment: new_attributes }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "for an admin" do
      before { login(admin) }

      it "destroys the requested issue_comment" do
        issue_comment = Fabricate(:issue_comment, issue: issue)
        expect do
          delete :destroy, params: { issue_id: issue.to_param,
                                     id: issue_comment.to_param }
        end.to change(IssueComment, :count).by(-1)
      end

      it "redirects to the issue_comments list" do
        issue_comment = Fabricate(:issue_comment, issue: issue)
        delete :destroy, params: { issue_id: issue.to_param,
                                   id: issue_comment.to_param }
        expect(response).to redirect_to(issue_url(issue))
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "doesn't destroy the requested issue_comment" do
          issue_comment = Fabricate(:issue_comment, issue: issue)
          expect do
            delete :destroy, params: { issue_id: issue.to_param,
                                       id: issue_comment.to_param }
          end.not_to change(IssueComment, :count)
        end

        it "should be unauthorized" do
          issue_comment = Fabricate(:issue_comment, issue: issue)
          delete :destroy, params: { issue_id: issue.to_param,
                                     id: issue_comment.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
