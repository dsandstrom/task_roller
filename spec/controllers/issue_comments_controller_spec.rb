require "rails_helper"

RSpec.describe IssueCommentsController, type: :controller do
  include ActiveJob::TestHelper

  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue) { Fabricate(:issue, project: project) }
  let(:admin) { Fabricate(:user_admin) }

  let(:valid_attributes) { { body: "Body" } }
  let(:invalid_attributes) { { body: "" } }

  describe "GET #new" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type.downcase}")) }

        context "when html request" do
          it "returns a success response" do
            get :new, params: { issue_id: issue.to_param }
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "GET #edit" do
    context "for an admin" do
      before { sign_in(admin) }

      context "for their own IssueComment" do
        context "when html request" do
          it "returns a success response" do
            issue_comment = Fabricate(:issue_comment, issue: issue, user: admin)
            get :edit, params: { issue_id: issue.to_param,
                                 id: issue_comment.to_param }
            expect(response).to be_successful
          end
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

        before { sign_in(current_user) }

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

  describe "GET #show" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type.downcase}")) }

        context "when html request" do
          it "returns a success response" do
            issue_comment = Fabricate(:issue_comment, issue: issue)
            url = issue_url(issue, anchor: "comment-#{issue_comment.id}")
            get :show, params: { issue_id: issue.to_param,
                                 id: issue_comment.to_param }
            expect(response).to redirect_to(url)
          end
        end
      end
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      { issue_id: issue.to_param, issue_comment: valid_attributes }
    end

    let(:invalid_params) do
      { issue_id: issue.to_param, issue_comment: invalid_attributes }
    end

    let(:job_options) do
      { event: "comment", issue_comment: IssueComment.last,
        current_user: current_user }
    end

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "with valid params" do
          context "when html request" do
            it "creates a new IssueComment" do
              expect do
                post :create, params: valid_params
              end.to change(current_user.issue_comments, :count).by(1)
            end

            it "enqueues IssueSubscribersNotifierJob" do
              post :create, params: valid_params

              expect(IssueSubscribersNotifierJob)
                .to have_been_enqueued.exactly(:once)
              expect(IssueSubscribersNotifierJob)
                .to have_been_enqueued.with(issue, job_options)
            end

            it "redirects to the created issue_comment" do
              post :create, params: valid_params
              anchor = "comment-#{IssueComment.last.id}"
              url = issue_url(issue, anchor: anchor)
              expect(response).to redirect_to(url)
            end

            context "when not subscribed to issue" do
              it "creates a new IssueSubscription" do
                expect do
                  post :create, params: valid_params
                end.to change(current_user.issue_subscriptions, :count).by(1)
              end
            end

            context "when already subscribed to issue" do
              before do
                Fabricate(:issue_subscription, issue: issue, user: current_user)
              end

              it "doesn't create a new IssueSubscription" do
                expect do
                  post :create, params: valid_params
                end.not_to change(IssueSubscription, :count)
              end
            end
          end

          context "when turbo_stream request" do
            it "creates a new IssueComment" do
              expect do
                post :create, params: valid_params, as: :turbo_stream
              end.to change(current_user.issue_comments, :count).by(1)
            end

            it "enqueues IssueSubscribersNotifierJob" do
              post :create, params: valid_params, as: :turbo_stream

              expect(IssueSubscribersNotifierJob)
                .to have_been_enqueued.exactly(:once)
              expect(IssueSubscribersNotifierJob)
                .to have_been_enqueued.with(issue, job_options)
            end

            it "redirects to the created issue_comment" do
              post :create, params: valid_params, as: :turbo_stream
              expect(response).to be_successful
            end
          end
        end

        context "with invalid params" do
          context "when html request" do
            it "doesn't create a new IssueComment" do
              expect do
                post :create, params: invalid_params
              end.not_to change(IssueComment, :count)
            end

            it "doesn't enqueue any jobs" do
              expect do
                post :create, params: invalid_params
              end.not_to have_enqueued_job
            end

            it "returns a success response ('new' template)" do
              post :create, params: invalid_params
              expect(response).to be_successful
            end
          end

          context "when turbo_stream request" do
            it "doesn't create a new IssueComment" do
              expect do
                post :create, params: invalid_params, as: :turbo_stream
              end.not_to change(IssueComment, :count)
            end

            it "doesn't enqueue any jobs" do
              expect do
                post :create, params: invalid_params, as: :turbo_stream
              end.not_to have_enqueued_job
            end

            it "returns a success response ('new' template)" do
              post :create, params: invalid_params, as: :turbo_stream
              expect(response).to be_successful
            end
          end
        end
      end
    end
  end

  describe "PUT #update" do
    let(:new_attributes) { { body: "New body" } }

    let(:valid_params) do
      { issue_id: issue.to_param, id: issue_comment.to_param,
        issue_comment: new_attributes }
    end

    let(:invalid_params) do
      { issue_id: issue.to_param, id: issue_comment.to_param,
        issue_comment: invalid_attributes }
    end

    context "for an admin" do
      before { sign_in(admin) }

      context "for their own IssueComment" do
        let!(:issue_comment) do
          Fabricate(:issue_comment, issue: issue, user: admin)
        end

        context "when html request" do
          context "with valid params" do
            it "updates the requested issue_comment" do
              expect do
                put :update, params: valid_params
                issue_comment.reload
              end.to change(issue_comment, :body).to("New body")
            end

            it "redirects to the issue_comment" do
              url = issue_url(issue, anchor: "comment-#{issue_comment.id}")
              put :update, params: valid_params
              expect(response).to redirect_to(url)
            end
          end

          context "with invalid params" do
            it "returns a success response ('edit' template)" do
              put :update, params: invalid_params
              expect(response).to be_successful
            end
          end
        end

        context "when turbo_stream request" do
          context "with valid params" do
            it "updates the requested issue_comment" do
              expect do
                put :update, params: valid_params, as: :turbo_stream
                issue_comment.reload
              end.to change(issue_comment, :body).to("New body")
            end

            it "redirects to the issue_comment" do
              url = issue_url(issue, anchor: "comment-#{issue_comment.id}")
              put :update, params: valid_params, as: :turbo_stream
              expect(response).to redirect_to(url)
            end
          end

          context "with invalid params" do
            it "returns a success response ('edit' template)" do
              put :update, params: invalid_params, as: :turbo_stream
              expect(response).to be_successful
            end
          end
        end
      end

      context "for someone else's IssueComment" do
        let!(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

        context "with valid params" do
          it "updates the requested issue_comment" do
            expect do
              put :update, params: valid_params
              issue_comment.reload
            end.to change(issue_comment, :body).to("New body")
          end

          it "redirects to the issue_comment" do
            url = issue_url(issue, anchor: "comment-#{issue_comment.id}")
            put :update, params: valid_params
            expect(response).to redirect_to(url)
          end
        end

        context "with invalid params" do
          it "returns a success response ('edit' template)" do
            put :update, params: invalid_params
            expect(response).to be_successful
          end
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "for their own IssueComment" do
          let!(:issue_comment) do
            Fabricate(:issue_comment, issue: issue, user: current_user)
          end

          context "when html request" do
            context "with valid params" do
              it "updates the requested issue_comment" do
                expect do
                  put :update, params: valid_params
                  issue_comment.reload
                end.to change(issue_comment, :body).to("New body")
              end

              it "redirects to the issue_comment" do
                url = issue_url(issue, anchor: "comment-#{issue_comment.id}")
                put :update, params: valid_params
                expect(response).to redirect_to(url)
              end
            end

            context "with invalid params" do
              it "returns a success response ('edit' template)" do
                put :update, params: invalid_params
                expect(response).to be_successful
              end
            end
          end

          context "when turbo_stream request" do
            context "with valid params" do
              it "updates the requested issue_comment" do
                expect do
                  put :update, params: valid_params, as: :turbo_stream
                  issue_comment.reload
                end.to change(issue_comment, :body).to("New body")
              end

              it "redirects to the issue_comment" do
                url = issue_url(issue, anchor: "comment-#{issue_comment.id}")
                put :update, params: valid_params, as: :turbo_stream
                expect(response).to redirect_to(url)
              end
            end

            context "with invalid params" do
              it "returns a success response ('edit' template)" do
                put :update, params: invalid_params, as: :turbo_stream
                expect(response).to be_successful
              end
            end
          end
        end

        context "for someone else's IssueComment" do
          let!(:issue_comment) { Fabricate(:issue_comment, issue: issue) }

          context "when html request" do
            it "doesn't update the requested issue_comment" do
              expect do
                put :update, params: valid_params
                issue_comment.reload
              end.not_to change(issue_comment, :body)
            end

            it "should be unauthorized" do
              put :update, params: valid_params
              expect_to_be_unauthorized(response)
            end
          end

          context "when turbo_stream request" do
            it "doesn't update the requested issue_comment" do
              expect do
                put :update, params: valid_params, as: :turbo_stream
                issue_comment.reload
              end.not_to change(issue_comment, :body)
            end

            it "should be unauthorized" do
              put :update, params: valid_params, as: :turbo_stream
              expect(response).to have_http_status(403)
            end
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:issue_comment) { Fabricate(:issue_comment, issue: issue) }
    let(:params) { { issue_id: issue.to_param, id: issue_comment.to_param } }

    context "for an admin" do
      before { sign_in(admin) }

      context "when html request" do
        it "destroys the requested issue_comment" do
          expect do
            delete :destroy, params: params
          end.to change(IssueComment, :count).by(-1)
        end

        it "redirects to the issue_comments list" do
          delete :destroy, params: params
          expect(response).to redirect_to(issue_url(issue))
        end
      end

      context "when turbo_stream request" do
        it "destroys the requested issue_comment" do
          expect do
            delete :destroy, params: params, as: :turbo_stream
          end.to change(IssueComment, :count).by(-1)
        end

        it "returns a success response" do
          delete :destroy, params: params, as: :turbo_stream
          expect(response).to be_successful
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when html request" do
          it "doesn't destroy the requested issue_comment" do
            expect do
              delete :destroy, params: params
            end.not_to change(IssueComment, :count)
          end

          it "should be unauthorized" do
            delete :destroy, params: params
            expect_to_be_unauthorized(response)
          end
        end

        context "when turbo_stream request" do
          it "doesn't destroy the requested issue_comment" do
            expect do
              delete :destroy, params: params, as: :turbo_stream
            end.not_to change(IssueComment, :count)
          end

          it "should be unauthorized" do
            delete :destroy, params: params, as: :turbo_stream
            expect(response).to have_http_status(403)
          end
        end
      end
    end
  end
end
