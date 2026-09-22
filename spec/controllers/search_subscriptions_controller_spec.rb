require "rails_helper"

RSpec.describe SearchSubscriptionsController, type: :controller do
  let(:user) { Fabricate(:user) }
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }

  let(:valid_attributes) { { term: "Search Term" } }
  let(:invalid_attributes) { { term: "" } }

  before do
    Fabricate(:issue_type)
    Fabricate(:task_type)
  end

  describe "GET #index" do
    %w[admin reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when they have a SearchSubscription" do
          before do
            Fabricate(:search_subscription, user: current_user)
          end

          it "returns a success response" do
            get :index
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "GET #show" do
    %w[admin reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when the SearchSubscription belongs to them" do
          let!(:search_subscription) do
            Fabricate(:search_subscription, user: current_user)
          end

          it "returns a success response" do
            get :show, params: { id: search_subscription.to_param }
            expect(response).to be_successful
          end
        end

        context "when the SearchSubscription doesn't belong to them" do
          let!(:search_subscription) { Fabricate(:search_subscription) }

          it "should raise error" do
            expect do
              get :show, params: { id: search_subscription.to_param }
            end.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end

  describe "GET #new" do
    %w[admin reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when the SearchSubscription belongs to them" do
          it "returns a success response" do
            get :new
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "POST #create" do
    %w[admin reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when valid params" do
          it "creates a new SearchSubscription" do
            expect do
              post :create, params: { search_subscription: valid_attributes }
            end.to change(current_user.search_subscriptions, :count).by(1)
          end

          it "redirects to search_subscriptions" do
            post :create, params: { search_subscription: valid_attributes }
            expect(response).to redirect_to(:search_subscriptions)
          end
        end

        context "when invalid params" do
          it "doesn't create a SearchSubscription" do
            expect do
              post :create, params: { search_subscription: invalid_attributes }
            end.not_to change(SearchSubscription, :count)
          end

          it "renders new" do
            post :create, params: { search_subscription: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "PATCH #toggle" do
    %w[admin reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when the SearchSubscription belongs to them" do
          context "that is active" do
            let!(:search_subscription) do
              Fabricate(:search_subscription, user: current_user)
            end

            it "updates the SearchSubscription" do
              expect do
                patch :toggle, params: { id: search_subscription.to_param }
                search_subscription.reload
              end.to change(search_subscription, :active).to(false)
            end

            it "redirects to search_subscriptions" do
              patch :toggle, params: { id: search_subscription.to_param }
              expect(response).to redirect_to(:search_subscriptions)
            end
          end

          context "that is inactive" do
            let!(:search_subscription) do
              Fabricate(:inactive_search_subscription, user: current_user)
            end

            it "updates the SearchSubscription" do
              expect do
                patch :toggle, params: { id: search_subscription.to_param }
                search_subscription.reload
              end.to change(search_subscription, :active).to(true)
            end

            it "redirects to search_subscriptions" do
              patch :toggle, params: { id: search_subscription.to_param }
              expect(response).to redirect_to(:search_subscriptions)
            end
          end
        end

        context "when the SearchSubscription doesn't belong to them" do
          let!(:search_subscription) { Fabricate(:search_subscription) }

          it "raises error" do
            expect do
              patch :toggle, params: { id: search_subscription.to_param }
            end.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end

  describe "DELETE :destroy" do
    %w[admin reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when the SearchSubscription belongs to them" do
          let!(:search_subscription) do
            Fabricate(:search_subscription, user: current_user)
          end

          it "destroys the SearchSubscription" do
            expect do
              delete :destroy, params: { id: search_subscription.to_param }
            end.to change(SearchSubscription, :count).by(-1)
          end

          it "redirects to search_subscriptions" do
            delete :destroy, params: { id: search_subscription.to_param }
            expect(response).to redirect_to(:search_subscriptions)
          end
        end

        context "when the SearchSubscription doesn't belong to them" do
          let!(:search_subscription) { Fabricate(:search_subscription) }

          it "raises error" do
            expect do
              delete :destroy, params: { id: search_subscription.to_param }
            end.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
