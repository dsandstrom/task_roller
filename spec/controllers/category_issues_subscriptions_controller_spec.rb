require "rails_helper"

RSpec.describe CategoryIssuesSubscriptionsController, type: :controller do
  let(:category) { Fabricate(:category) }
  let(:user) { Fabricate(:user_worker) }

  describe "GET #new" do
    let(:params) { { category_id: category.to_param } }

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
    let(:params) { { category_id: category.to_param } }

    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when html request" do
          context "for a visible and internal category" do
            let(:category) { Fabricate(:category, internal: true) }

            context "with valid params" do
              it "creates a new CategoryIssuesSubscription" do
                expect do
                  post :create, params: params
                end.to change(
                  current_user.category_issues_subscriptions,
                  :count
                ).by(1)
              end

              it "redirects to the requested category" do
                post :create, params: params
                expect(response).to redirect_to(category)
              end
            end

            context "with invalid params" do
              before do
                Fabricate(:category_issues_subscription, category: category,
                                                         user: current_user)
              end

              it "doesn't create a new CategoryIssuesSubscription" do
                expect do
                  post :create, params: params
                end.not_to change(CategoryIssuesSubscription, :count)
              end

              it "renders new" do
                post :create, params: params
                expect(response).to be_successful
              end
            end
          end

          context "for an invisible and external category" do
            let(:category) { Fabricate(:invisible_category) }

            it "doesn't create a new CategoryIssuesSubscription" do
              expect do
                post :create, params: params
              end.not_to change(CategoryIssuesSubscription, :count)
            end

            it "should be unauthorized" do
              post :create, params: params
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "when turbo_stream request" do
          context "for a visible and internal category" do
            let(:category) { Fabricate(:category, internal: true) }

            context "with valid params" do
              it "creates a new CategoryIssuesSubscription" do
                expect do
                  post :create, params: params, as: :turbo_stream
                end.to change(
                  current_user.category_issues_subscriptions,
                  :count
                ).by(1)
              end

              it "redirects to the requested category" do
                post :create, params: params, as: :turbo_stream
                expect(response).to redirect_to(category)
              end
            end

            context "with invalid params" do
              before do
                Fabricate(:category_issues_subscription, category: category,
                                                         user: current_user)
              end

              it "doesn't create a new CategoryIssuesSubscription" do
                expect do
                  post :create, params: params, as: :turbo_stream
                end.not_to change(CategoryIssuesSubscription, :count)
              end

              it "renders new" do
                post :create, params: params, as: :turbo_stream
                expect(response).to be_successful
              end
            end
          end

          context "for an invisible and external category" do
            let(:category) { Fabricate(:invisible_category) }

            it "doesn't create a new CategoryIssuesSubscription" do
              expect do
                post :create, params: params, as: :turbo_stream
              end.not_to change(CategoryIssuesSubscription, :count)
            end

            it "should be unauthorized" do
              post :create, params: params, as: :turbo_stream
              expect(response).to have_http_status(:forbidden)
            end
          end
        end
      end
    end

    %w[worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when html request" do
          context "for a visible" do
            context "and external category" do
              context "with valid params" do
                it "creates a new CategoryIssuesSubscription" do
                  expect do
                    post :create, params: params
                  end.to change(
                    current_user.category_issues_subscriptions,
                    :count
                  ).by(1)
                end

                it "redirects to the requested category" do
                  post :create, params: params
                  expect(response).to redirect_to(category)
                end
              end

              context "with invalid params" do
                before do
                  Fabricate(:category_issues_subscription, category: category,
                                                           user: current_user)
                end

                it "doesn't create a new CategoryIssuesSubscription" do
                  expect do
                    post :create, params: params
                  end.not_to change(CategoryIssuesSubscription, :count)
                end

                it "renders new" do
                  post :create, params: params
                  expect(response).to be_successful
                end
              end
            end

            context "and internal category" do
              let(:category) { Fabricate(:internal_category) }

              context "with valid params" do
                it "creates a new CategoryIssuesSubscription" do
                  expect do
                    post :create, params: params
                  end.to change(
                    current_user.category_issues_subscriptions,
                    :count
                  ).by(1)
                end

                it "redirects to the requested category" do
                  post :create, params: params
                  expect(response).to redirect_to(category)
                end
              end

              context "with invalid params" do
                before do
                  Fabricate(:category_issues_subscription, category: category,
                                                           user: current_user)
                end

                it "doesn't create a new CategoryIssuesSubscription" do
                  expect do
                    post :create, params: params
                  end.not_to change(CategoryIssuesSubscription, :count)
                end

                it "renders new" do
                  post :create, params: params
                  expect(response).to be_successful
                end
              end
            end
          end

          context "for an invisible" do
            context "and external category" do
              let(:category) { Fabricate(:invisible_category) }

              it "doesn't create a new CategoryIssuesSubscription" do
                expect do
                  post :create, params: params
                end.not_to change(CategoryIssuesSubscription, :count)
              end

              it "should be unauthorized" do
                post :create, params: params
                expect_to_be_unauthorized(response)
              end
            end

            context "and internal category" do
              let(:category) { Fabricate(:invisible_category, internal: false) }

              it "doesn't create a new CategoryIssuesSubscription" do
                expect do
                  post :create, params: params
                end.not_to change(CategoryIssuesSubscription, :count)
              end

              it "should be unauthorized" do
                post :create, params: params
                expect_to_be_unauthorized(response)
              end
            end
          end
        end
      end
    end

    %w[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "for a visible" do
          context "and external category" do
            context "with valid params" do
              it "creates a new CategoryIssuesSubscription" do
                expect do
                  post :create, params: params
                end.to change(
                  current_user.category_issues_subscriptions,
                  :count
                ).by(1)
              end

              it "redirects to the requested category" do
                post :create, params: params
                expect(response).to redirect_to(category)
              end
            end

            context "with invalid params" do
              before do
                Fabricate(:category_issues_subscription, category: category,
                                                         user: current_user)
              end

              it "doesn't create a new CategoryIssuesSubscription" do
                expect do
                  post :create, params: params
                end.not_to change(CategoryIssuesSubscription, :count)
              end

              it "renders new" do
                post :create, params: params
                expect(response).to be_successful
              end
            end
          end

          context "and internal category" do
            let(:category) { Fabricate(:internal_category) }

            it "doesn't create a new CategoryIssuesSubscription" do
              expect do
                post :create, params: params
              end.not_to change(CategoryIssuesSubscription, :count)
            end

            it "should be unauthorized" do
              post :create, params: params
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "for an invisible" do
          context "and external category" do
            let(:category) { Fabricate(:invisible_category) }

            it "doesn't create a new CategoryIssuesSubscription" do
              expect do
                post :create, params: params
              end.not_to change(CategoryIssuesSubscription, :count)
            end

            it "should be unauthorized" do
              post :create, params: params
              expect_to_be_unauthorized(response)
            end
          end

          context "and internal category" do
            let(:category) { Fabricate(:invisible_category, internal: false) }

            it "doesn't create a new CategoryIssuesSubscription" do
              expect do
                post :create, params: params
              end.not_to change(CategoryIssuesSubscription, :count)
            end

            it "should be unauthorized" do
              post :create, params: params
              expect_to_be_unauthorized(response)
            end
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:params) do
      { category_id: category.to_param, id: subscription.to_param }
    end

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when html request" do
          context "when their category_issues_subscription" do
            let!(:subscription) do
              Fabricate(:category_issues_subscription, category: category,
                                                       user: current_user)
            end

            it "destroys the requested category_issues_subscription" do
              expect do
                delete :destroy, params: params
              end.to change(current_user.category_issues_subscriptions, :count)
                .by(-1)
            end

            it "redirects to the requested category" do
              delete :destroy, params: params
              expect(response).to redirect_to(category)
            end
          end

          context "when someone else's category_issues_subscription" do
            let!(:subscription) do
              Fabricate(:category_issues_subscription, category: category)
            end

            it "doesn't destroys the requested category_issues_subscription" do
              expect do
                delete :destroy, params: params
              end.not_to change(CategoryIssuesSubscription, :count)
            end

            it "should be unauthorized" do
              delete :destroy, params: params
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "when turbo_stream request" do
          context "when their category_issues_subscription" do
            let!(:subscription) do
              Fabricate(:category_issues_subscription, category: category,
                                                       user: current_user)
            end

            it "destroys the requested category_issues_subscription" do
              expect do
                delete :destroy, params: params, as: :turbo_stream
              end.to change(
                current_user.category_issues_subscriptions,
                :count
              ).by(-1)
            end

            it "renders :new" do
              delete :destroy, params: params, as: :turbo_stream
              expect(response).to be_successful
            end
          end

          context "when someone else's category_issues_subscription" do
            let!(:subscription) do
              Fabricate(:category_issues_subscription, category: category)
            end

            it "doesn't destroys the requested category_issues_subscription" do
              expect do
                delete :destroy, params: params, as: :turbo_stream
              end.not_to change(CategoryIssuesSubscription, :count)
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
