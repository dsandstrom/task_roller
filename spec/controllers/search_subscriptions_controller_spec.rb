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
    %w[admin reviewer worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let(:filters) { { query: "search term", order: "updated,desc" } }

        before { sign_in(current_user) }

        context "when the SearchSubscription belongs to them" do
          let!(:search_subscription) do
            Fabricate(:search_subscription, user: current_user)
          end

          it "redirects to search_results" do
            get :show, params: { id: search_subscription.to_param }
            expect(response).to redirect_to(search_results_url(filters))
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

    context "for a reporter" do
      let(:current_user) { Fabricate(:user_reporter) }
      let(:source_user) { Fabricate(:user) }
      let(:category) { Fabricate(:category) }
      let(:project) { Fabricate(:project) }
      let(:issue_type) { Fabricate(:issue_type) }
      let(:task_type) { Fabricate(:task_type) }
      let(:issue_status) { "addressed" }
      let(:task_status) { "approved" }

      let(:default_filters) do
        { query: search_subscription.term, order: "updated,desc" }
      end

      let(:default_issue_filters) do
        { query: search_subscription.term, type: "issues",
          issue_status: "all", issue_type_id: "all",
          order: "updated,desc" }
      end

      let(:default_task_filters) do
        { query: search_subscription.term, type: "tasks",
          task_status: "all", task_type_id: "all",
          order: "updated,desc" }
      end

      before { sign_in(current_user) }

      context "when no source" do
        context "and only term is set" do
          context "when the SearchSubscription belongs to them" do
            let(:search_subscription) do
              Fabricate(:search_subscription, user: current_user)
            end

            it "redirects to search_results_url" do
              get :show, params: { id: search_subscription.to_param }
              expect(response)
                .to redirect_to(search_results_url(default_filters))
            end
          end

          context "when the SearchSubscription doesn't belong to them" do
            let(:search_subscription) { Fabricate(:search_subscription) }

            it "should raise error" do
              expect do
                get :show, params: { id: search_subscription.to_param }
              end.to raise_error(ActiveRecord::RecordNotFound)
            end
          end
        end

        context "and including only issues" do
          let(:search_subscription) do
            Fabricate(:search_subscription, user: current_user,
                                            include_tasks: false)
          end

          it "redirects to search_results_url" do
            get :show, params: { id: search_subscription.to_param }
            expect(response)
              .to redirect_to(search_results_url(default_issue_filters))
          end
        end

        context "and including issues with issue attrs" do
          let(:filters) do
            { query: search_subscription.term, type: "issues",
              issue_status: issue_status, issue_type_id: issue_type.id,
              order: "updated,desc" }
          end

          let(:search_subscription) do
            Fabricate(:search_subscription, user: current_user,
                                            include_tasks: false,
                                            issue_type: issue_type,
                                            issue_status: issue_status)
          end

          it "redirects to search_results_url" do
            get :show, params: { id: search_subscription.to_param }
            expect(response).to redirect_to(search_results_url(filters))
          end
        end

        context " and including only tasks" do
          let(:search_subscription) do
            Fabricate(:search_subscription, user: current_user,
                                            include_issues: false)
          end

          it "redirects to search_results_url" do
            get :show, params: { id: search_subscription.to_param }
            expect(response)
              .to redirect_to(search_results_url(default_task_filters))
          end
        end

        context "and including tasks with task attrs" do
          let(:filters) do
            { query: search_subscription.term, type: "tasks",
              task_status: task_status, task_type_id: task_type.id,
              order: "updated,desc" }
          end

          let(:search_subscription) do
            Fabricate(:search_subscription, user: current_user,
                                            include_issues: false,
                                            task_type: task_type,
                                            task_status: task_status)
          end

          it "redirects to search_results_url" do
            get :show, params: { id: search_subscription.to_param }
            expect(response).to redirect_to(search_results_url(filters))
          end
        end
      end

      context "when source user" do
        context "and including only issues" do
          let(:search_subscription) do
            Fabricate(:search_subscription, user: current_user,
                                            source_user: source_user,
                                            include_tasks: false)
          end

          it "redirects to user_issues" do
            get :show, params: { id: search_subscription.to_param }
            expect(response).to redirect_to(
              user_issues_url(source_user, default_issue_filters)
            )
          end
        end

        context "and including only tasks" do
          let(:search_subscription) do
            Fabricate(:search_subscription, user: current_user,
                                            source_user: source_user,
                                            include_issues: false)
          end

          it "redirects to user_tasks" do
            get :show, params: { id: search_subscription.to_param }
            expect(response).to redirect_to(
              user_tasks_url(source_user, default_task_filters)
            )
          end
        end

        context "and including issues and tasks" do
          let(:search_subscription) do
            Fabricate(:search_subscription, user: current_user,
                                            source_user: source_user)
          end

          it "redirects to user_issues" do
            get :show, params: { id: search_subscription.to_param }
            expect(response)
              .to redirect_to(user_issues_url(source_user, default_filters))
          end
        end
      end

      context "when source category" do
        context "and including only issues" do
          let(:search_subscription) do
            Fabricate(:search_subscription, user: current_user,
                                            category: category,
                                            include_tasks: false)
          end

          it "redirects to category_issues" do
            get :show, params: { id: search_subscription.to_param }
            expect(response).to redirect_to(
              category_issues_url(category, default_issue_filters)
            )
          end
        end

        context "and including only tasks" do
          let(:search_subscription) do
            Fabricate(:search_subscription, user: current_user,
                                            category: category,
                                            include_issues: false)
          end

          it "redirects to category_tasks" do
            get :show, params: { id: search_subscription.to_param }
            expect(response).to redirect_to(
              category_tasks_url(category, default_task_filters)
            )
          end
        end

        context "and including issues and tasks" do
          let(:search_subscription) do
            Fabricate(:search_subscription, user: current_user,
                                            category: category)
          end

          it "redirects to category" do
            get :show, params: { id: search_subscription.to_param }
            expect(response)
              .to redirect_to(category_url(category, default_filters))
          end
        end
      end

      context "when source project" do
        context "and including only issues" do
          let(:search_subscription) do
            Fabricate(:search_subscription, user: current_user,
                                            project: project,
                                            include_tasks: false)
          end

          it "redirects to project_issues" do
            get :show, params: { id: search_subscription.to_param }
            expect(response).to redirect_to(
              project_issues_url(project, default_issue_filters)
            )
          end
        end

        context "and including only tasks" do
          let(:search_subscription) do
            Fabricate(:search_subscription, user: current_user,
                                            project: project,
                                            include_issues: false)
          end

          it "redirects to project_tasks" do
            get :show, params: { id: search_subscription.to_param }
            expect(response).to redirect_to(
              project_tasks_url(project, default_task_filters)
            )
          end
        end

        context "and including issues and tasks" do
          let(:search_subscription) do
            Fabricate(:search_subscription, user: current_user,
                                            project: project)
          end

          it "redirects to project" do
            get :show, params: { id: search_subscription.to_param }
            expect(response)
              .to redirect_to(project_url(project, default_filters))
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
            expect(response).to redirect_to(search_subscriptions_url)
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

        context "when params match an existing SearchSubscription" do
          before do
            current_user.search_subscriptions.build(valid_attributes).save
            valid_attributes.merge!(issue_status: "", task_status: "")
          end

          it "doesn't create a new SearchSubscription" do
            expect do
              post :create, params: { search_subscription: valid_attributes }
            end.not_to change(SearchSubscription, :count)
          end

          it "redirects to search_subscriptions" do
            post :create, params: { search_subscription: valid_attributes }
            expect(response).to redirect_to(search_subscriptions_url)
          end
        end

        context "when params match an existing inactive SearchSubscription" do
          let(:search_subscription) do
            Fabricate(:search_subscription, user: current_user,
                                            **valid_attributes)
          end

          before do
            search_subscription.update(active: false)
          end

          it "doesn't create a new SearchSubscription" do
            expect do
              post :create, params: { search_subscription: valid_attributes }
            end.not_to change(SearchSubscription, :count)
          end

          it "activates the current SearchSubscription" do
            expect do
              post :create, params: { search_subscription: valid_attributes }
              search_subscription.reload
            end.to change(search_subscription, :active).to(true)
          end

          it "redirects to search_subscriptions" do
            post :create, params: { search_subscription: valid_attributes }
            expect(response).to redirect_to(search_subscriptions_url)
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
