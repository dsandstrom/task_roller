# frozen_string_literal: true

require "rails_helper"

RSpec.describe CategoryTasksSubscriptionsController, type: :controller do
  let(:category) { Fabricate(:category) }
  let(:user) { Fabricate(:user_worker) }

  describe "GET #new" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        it "returns a success response" do
          get :new, params: { category_id: category.to_param }
          expect(response).to be_successful
        end
      end
    end
  end

  describe "POST #create" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when html request" do
          context "for a visible and internal category" do
            let(:category) { Fabricate(:internal_category) }

            context "with valid params" do
              it "creates a new CategoryTasksSubscription" do
                expect do
                  post :create, params: { category_id: category.to_param }
                end.to change(current_user.category_tasks_subscriptions, :count)
                  .by(1)
              end

              it "redirects to the requested category" do
                post :create, params: { category_id: category.to_param }
                expect(response).to redirect_to(category)
              end
            end

            context "with invalid params" do
              before do
                Fabricate(:category_tasks_subscription, category: category,
                                                        user: current_user)
              end

              it "doesn't create a new CategoryTasksSubscription" do
                expect do
                  post :create, params: { category_id: category.to_param }
                end.not_to change(CategoryTasksSubscription, :count)
              end

              it "renders new" do
                post :create, params: { category_id: category.to_param }
                expect(response).to be_successful
              end
            end
          end

          context "for an invisible and external category" do
            let(:category) { Fabricate(:invisible_category) }

            it "doesn't create a new CategoryTasksSubscription" do
              expect do
                post :create, params: { category_id: category.to_param }
              end.not_to change(CategoryTasksSubscription, :count)
            end

            it "should be unauthorized" do
              post :create, params: { category_id: category.to_param }
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "when js request" do
          context "for a visible and internal category" do
            let(:category) { Fabricate(:internal_category) }

            context "with valid params" do
              it "creates a new CategoryTasksSubscription" do
                expect do
                  post :create, params: { category_id: category.to_param },
                                xhr: true
                end.to change(current_user.category_tasks_subscriptions, :count)
                  .by(1)
              end

              it "renders :show" do
                post :create, params: { category_id: category.to_param },
                              xhr: true
                expect(response).to be_successful
              end
            end

            context "with invalid params" do
              before do
                Fabricate(:category_tasks_subscription, category: category,
                                                        user: current_user)
              end

              it "doesn't create a new CategoryTasksSubscription" do
                expect do
                  post :create, params: { category_id: category.to_param },
                                xhr: true
                end.not_to change(CategoryTasksSubscription, :count)
              end

              it "renders new" do
                post :create, params: { category_id: category.to_param },
                              xhr: true
                expect(response).to be_successful
              end
            end
          end

          context "for an invisible and external category" do
            let(:category) { Fabricate(:invisible_category) }

            it "doesn't create a new CategoryTasksSubscription" do
              expect do
                post :create, params: { category_id: category.to_param },
                              xhr: true
              end.not_to change(CategoryTasksSubscription, :count)
            end

            it "should be unauthorized" do
              post :create, params: { category_id: category.to_param },
                            xhr: true
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

        context "for a visible" do
          context "and external category" do
            context "with valid params" do
              it "creates a new CategoryTasksSubscription" do
                expect do
                  post :create, params: { category_id: category.to_param }
                end.to change(current_user.category_tasks_subscriptions,
                              :count).by(1)
              end

              it "redirects to the requested category" do
                post :create, params: { category_id: category.to_param }
                expect(response).to redirect_to(category)
              end
            end

            context "with invalid params" do
              before do
                Fabricate(:category_tasks_subscription, category: category,
                                                        user: current_user)
              end

              it "doesn't create a new CategoryTasksSubscription" do
                expect do
                  post :create, params: { category_id: category.to_param }
                end.not_to change(CategoryTasksSubscription, :count)
              end

              it "renders new" do
                post :create, params: { category_id: category.to_param }
                expect(response).to be_successful
              end
            end
          end

          context "and internal category" do
            let(:category) { Fabricate(:internal_category) }

            context "with valid params" do
              it "creates a new CategoryTasksSubscription" do
                expect do
                  post :create, params: { category_id: category.to_param }
                end.to change(current_user.category_tasks_subscriptions,
                              :count).by(1)
              end

              it "redirects to the requested category" do
                post :create, params: { category_id: category.to_param }
                expect(response).to redirect_to(category)
              end
            end

            context "with invalid params" do
              before do
                Fabricate(:category_tasks_subscription, category: category,
                                                        user: current_user)
              end

              it "doesn't create a new CategoryTasksSubscription" do
                expect do
                  post :create, params: { category_id: category.to_param }
                end.not_to change(CategoryTasksSubscription, :count)
              end

              it "renders new" do
                post :create, params: { category_id: category.to_param }
                expect(response).to be_successful
              end
            end
          end
        end

        context "for an invisible" do
          context "and external category" do
            let(:category) { Fabricate(:invisible_category) }

            it "doesn't create a new CategoryTasksSubscription" do
              expect do
                post :create, params: { category_id: category.to_param }
              end.not_to change(CategoryTasksSubscription, :count)
            end

            it "should be unauthorized" do
              post :create, params: { category_id: category.to_param }
              expect_to_be_unauthorized(response)
            end
          end

          context "and internal category" do
            let(:category) { Fabricate(:invisible_category, internal: false) }

            it "doesn't create a new CategoryTasksSubscription" do
              expect do
                post :create, params: { category_id: category.to_param }
              end.not_to change(CategoryTasksSubscription, :count)
            end

            it "should be unauthorized" do
              post :create, params: { category_id: category.to_param }
              expect_to_be_unauthorized(response)
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
              it "creates a new CategoryTasksSubscription" do
                expect do
                  post :create, params: { category_id: category.to_param }
                end.to change(current_user.category_tasks_subscriptions,
                              :count).by(1)
              end

              it "redirects to the requested category" do
                post :create, params: { category_id: category.to_param }
                expect(response).to redirect_to(category)
              end
            end

            context "with invalid params" do
              before do
                Fabricate(:category_tasks_subscription, category: category,
                                                        user: current_user)
              end

              it "doesn't create a new CategoryTasksSubscription" do
                expect do
                  post :create, params: { category_id: category.to_param }
                end.not_to change(CategoryTasksSubscription, :count)
              end

              it "renders new" do
                post :create, params: { category_id: category.to_param }
                expect(response).to be_successful
              end
            end
          end

          context "and internal category" do
            let(:category) { Fabricate(:internal_category) }

            it "doesn't create a new CategoryTasksSubscription" do
              expect do
                post :create, params: { category_id: category.to_param }
              end.not_to change(CategoryTasksSubscription, :count)
            end

            it "should be unauthorized" do
              post :create, params: { category_id: category.to_param }
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "for an invisible" do
          context "and external category" do
            let(:category) { Fabricate(:invisible_category) }

            it "doesn't create a new CategoryTasksSubscription" do
              expect do
                post :create, params: { category_id: category.to_param }
              end.not_to change(CategoryTasksSubscription, :count)
            end

            it "should be unauthorized" do
              post :create, params: { category_id: category.to_param }
              expect_to_be_unauthorized(response)
            end
          end

          context "and internal category" do
            let(:category) { Fabricate(:invisible_category, internal: false) }

            it "doesn't create a new CategoryTasksSubscription" do
              expect do
                post :create, params: { category_id: category.to_param }
              end.not_to change(CategoryTasksSubscription, :count)
            end

            it "should be unauthorized" do
              post :create, params: { category_id: category.to_param }
              expect_to_be_unauthorized(response)
            end
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when html request" do
          context "when their category_tasks_subscription" do
            it "destroys the requested category_tasks_subscription" do
              subscription =
                Fabricate(:category_tasks_subscription, category: category,
                                                        user: current_user)
              expect do
                delete :destroy, params: { category_id: category.to_param,
                                           id: subscription.to_param }
              end.to change(current_user.category_tasks_subscriptions, :count)
                .by(-1)
            end

            it "redirects to the requested category" do
              subscription =
                Fabricate(:category_tasks_subscription, category: category,
                                                        user: current_user)
              delete :destroy, params: { category_id: category.to_param,
                                         id: subscription.to_param }
              expect(response).to redirect_to(category)
            end
          end

          context "when someone else's category_tasks_subscription" do
            it "doesn't destroys the requested category_tasks_subscription" do
              subscription =
                Fabricate(:category_tasks_subscription, category: category)
              expect do
                delete :destroy, params: { category_id: category.to_param,
                                           id: subscription.to_param }
              end.not_to change(CategoryTasksSubscription, :count)
            end

            it "should be unauthorized" do
              subscription =
                Fabricate(:category_tasks_subscription, category: category)
              delete :destroy, params: { category_id: category.to_param,
                                         id: subscription.to_param }
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "when js request" do
          context "when their category_tasks_subscription" do
            it "destroys the requested category_tasks_subscription" do
              subscription =
                Fabricate(:category_tasks_subscription, category: category,
                                                        user: current_user)
              expect do
                delete :destroy, params: { category_id: category.to_param,
                                           id: subscription.to_param },
                                 xhr: true
              end.to change(current_user.category_tasks_subscriptions, :count)
                .by(-1)
            end

            it "renders :show" do
              subscription =
                Fabricate(:category_tasks_subscription, category: category,
                                                        user: current_user)
              delete :destroy, params: { category_id: category.to_param,
                                         id: subscription.to_param },
                               xhr: true
              expect(response).to be_successful
            end
          end

          context "when someone else's category_tasks_subscription" do
            it "doesn't destroys the requested category_tasks_subscription" do
              subscription =
                Fabricate(:category_tasks_subscription, category: category)
              expect do
                delete :destroy, params: { category_id: category.to_param,
                                           id: subscription.to_param },
                                 xhr: true
              end.not_to change(CategoryTasksSubscription, :count)
            end

            it "should be unauthorized" do
              subscription =
                Fabricate(:category_tasks_subscription, category: category)
              delete :destroy, params: { category_id: category.to_param,
                                         id: subscription.to_param },
                               xhr: true
              expect(response).to have_http_status(:forbidden)
            end
          end
        end
      end
    end
  end
end
