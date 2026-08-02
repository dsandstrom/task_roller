require "rails_helper"

RSpec.describe IssueSubscriptionsController, type: :controller do
  let(:issue) { Fabricate(:issue) }

  before do
    Fabricate(:issue_subscription)
  end

  describe "GET #new" do
    let(:params) { { issue_id: issue.to_param } }

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when html request" do
          it "returns a success response" do
            get :new, params: params
            expect(response).to be_successful
          end
        end

        context "when turbo_stream request" do
          it "returns a success response" do
            get :new, params: params, as: :turbo_stream
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "POST #create" do
    let(:params) { { issue_id: issue.to_param } }

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when html request" do
          context "with valid params" do
            it "creates a new IssueSubscription" do
              expect do
                post :create, params: params
              end.to change(current_user.issue_subscriptions, :count).by(1)
            end

            it "redirects to the requested issue" do
              post :create, params: params
              expect(response).to redirect_to(issue)
            end
          end

          context "with invalid params" do
            before do
              Fabricate(:issue_subscription, issue: issue, user: current_user)
            end

            it "doesn't create a new IssueSubscription" do
              expect do
                post :create, params: params
              end.not_to change(IssueSubscription, :count)
            end

            it "renders new" do
              post :create, params: params
              expect(response).to be_successful
            end
          end
        end

        context "when turbo_stream request" do
          context "with valid params" do
            it "creates a new IssueSubscription" do
              expect do
                post :create, params: params, as: :turbo_stream
              end.to change(current_user.issue_subscriptions, :count).by(1)
            end

            it "redirects to the requested issue" do
              post :create, params: params, as: :turbo_stream
              expect(response).to redirect_to(issue)
            end
          end

          context "with invalid params" do
            before do
              Fabricate(:issue_subscription, issue: issue, user: current_user)
            end

            it "doesn't create a new IssueSubscription" do
              expect do
                post :create, params: params, as: :turbo_stream
              end.not_to change(IssueSubscription, :count)
            end

            it "renders new" do
              post :create, params: params, as: :turbo_stream
              expect(response).to be_successful
            end
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:params) do
      { issue_id: issue.to_param, id: issue_subscription.to_param }
    end

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when html request" do
          context "when their issue_subscription" do
            let!(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue, user: current_user)
            end

            it "destroys the requested issue_subscription" do
              expect do
                delete :destroy, params: params
              end.to change(current_user.issue_subscriptions, :count).by(-1)
            end

            it "redirects to the issue" do
              delete :destroy, params: params
              expect(response).to redirect_to(issue)
            end
          end

          context "when someone else's issue_subscription" do
            let!(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue)
            end

            it "doesn't destroy the requested issue_subscription" do
              expect do
                delete :destroy, params: params
              end.not_to change(IssueSubscription, :count)
            end

            it "should be unauthorized" do
              delete :destroy, params: params
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "when turbo_stream request" do
          context "when their issue_subscription" do
            let!(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue, user: current_user)
            end

            it "destroys the requested issue_subscription" do
              expect do
                delete :destroy, params: params, as: :turbo_stream
              end.to change(current_user.issue_subscriptions, :count).by(-1)
            end

            it "redirects to the issue" do
              delete :destroy, params: params, as: :turbo_stream
              expect(response).to redirect_to(issue)
            end
          end

          context "when someone else's issue_subscription" do
            let!(:issue_subscription) do
              Fabricate(:issue_subscription, issue: issue)
            end

            it "doesn't destroy the requested issue_subscription" do
              expect do
                delete :destroy, params: params, as: :turbo_stream
              end.not_to change(IssueSubscription, :count)
            end

            it "should be unauthorized" do
              delete :destroy, params: params, as: :turbo_stream
              expect(response).to have_http_status(:forbidden)
            end
          end
        end
      end
    end
  end
end
