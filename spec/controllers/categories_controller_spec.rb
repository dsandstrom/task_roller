# frozen_string_literal: true

require "rails_helper"

RSpec.describe CategoriesController, type: :controller do
  let(:invalid_attributes) { { name: "" } }

  describe "GET #index" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type.downcase}")) }

        it "returns a success response" do
          _category = Fabricate(:category)
          get :index
          expect(response).to be_successful
        end
      end
    end
  end

  describe "GET #archived" do
    before { Fabricate(:invisible_category) }

    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type.downcase}")) }

        it "returns a success response" do
          get :archived
          expect(response).to be_successful
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          get :archived
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "GET #show" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        context "for a visible & external category" do
          let(:category) { Fabricate(:category) }

          context "when no filters" do
            it "returns a success response" do
              get :show, params: { id: category.to_param }
              expect(response).to be_successful
            end
          end

          context "when type filter is 'all'" do
            it "returns a success response" do
              get :show, params: { id: category.to_param, type: "all" }
              expect(response).to be_successful
            end
          end

          context "when type filter is 'issues'" do
            it "returns a success response" do
              get :show, params: { id: category.to_param, type: "issues",
                                   issue_status: "open" }
              url = category_issues_path(category, type: "issues",
                                                   issue_status: "open")
              expect(response).to redirect_to(url)
            end
          end

          context "when type filter is 'tasks'" do
            it "returns a success response" do
              get :show, params: { id: category.to_param, type: "tasks",
                                   task_status: "closed", invalid: "invalid" }
              url = category_tasks_path(category, type: "tasks",
                                                  task_status: "closed")
              expect(response).to redirect_to(url)
            end
          end
        end

        context "for an invisible category" do
          let(:category) { Fabricate(:invisible_category) }

          it "returns a success response" do
            get :show, params: { id: category.to_param }
            expect(response).to be_successful
          end
        end

        context "for an internal category" do
          let(:category) { Fabricate(:internal_category) }

          it "returns a success response" do
            get :show, params: { id: category.to_param }
            expect(response).to be_successful
          end
        end
      end

      context "for a worker" do
        before { sign_in(Fabricate(:user_worker)) }

        context "for a visible & external category" do
          let(:category) { Fabricate(:category) }

          context "when no filters" do
            it "returns a success response" do
              get :show, params: { id: category.to_param }
              expect(response).to be_successful
            end
          end

          context "when type filter is 'all'" do
            it "returns a success response" do
              get :show, params: { id: category.to_param, type: "all" }
              expect(response).to be_successful
            end
          end

          context "when type filter is 'issues'" do
            it "returns a success response" do
              get :show, params: { id: category.to_param, type: "issues",
                                   issue_status: "open" }
              url = category_issues_path(category, type: "issues",
                                                   issue_status: "open")
              expect(response).to redirect_to(url)
            end
          end

          context "when type filter is 'tasks'" do
            it "returns a success response" do
              get :show, params: { id: category.to_param, type: "tasks",
                                   task_status: "closed", invalid: "invalid" }
              url = category_tasks_path(category, type: "tasks",
                                                  task_status: "closed")
              expect(response).to redirect_to(url)
            end
          end
        end

        context "for an internal category" do
          let(:category) { Fabricate(:internal_category) }

          it "returns a success response" do
            get :show, params: { id: category.to_param }
            expect(response).to be_successful
          end
        end

        context "for an invisible category" do
          let(:category) { Fabricate(:invisible_category) }

          it "redirects to unauthorized" do
            get :show, params: { id: category.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end

      context "for a reporter" do
        before { sign_in(Fabricate(:user_reporter)) }

        context "for a visible & external category" do
          let(:category) { Fabricate(:category) }

          context "when no filters" do
            it "returns a success response" do
              get :show, params: { id: category.to_param }
              expect(response).to be_successful
            end
          end

          context "when type filter is 'all'" do
            it "returns a success response" do
              get :show, params: { id: category.to_param, type: "all" }
              expect(response).to be_successful
            end
          end

          context "when type filter is 'issues'" do
            it "returns a success response" do
              get :show, params: { id: category.to_param, type: "issues",
                                   issue_status: "open" }
              url = category_issues_path(category, type: "issues",
                                                   issue_status: "open")
              expect(response).to redirect_to(url)
            end
          end

          context "when type filter is 'tasks'" do
            it "returns a success response" do
              get :show, params: { id: category.to_param, type: "tasks",
                                   task_status: "closed", invalid: "invalid" }
              url = category_tasks_path(category, type: "tasks",
                                                  task_status: "closed")
              expect(response).to redirect_to(url)
            end
          end
        end

        context "for an internal category" do
          let(:category) { Fabricate(:internal_category) }

          it "redirects to unauthorized" do
            get :show, params: { id: category.to_param }
            expect_to_be_unauthorized(response)
          end
        end

        context "for an invisible category" do
          let(:category) { Fabricate(:invisible_category) }

          it "redirects to unauthorized" do
            get :show, params: { id: category.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "GET #new" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        it "returns a success response" do
          get :new
          expect(response).to be_successful
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          get :new, params: {}
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "GET #edit" do
    %w[admin reviewer].each do |employee_type|
      before { sign_in(Fabricate("user_#{employee_type}")) }

      it "returns a success response" do
        category = Fabricate(:category)
        get :edit, params: { id: category.to_param }
        expect(response).to be_successful
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          category = Fabricate(:category)
          get :edit, params: { id: category.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "POST #create" do
    let(:valid_attributes) { { name: "Category Name" } }

    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        context "with valid params" do
          it "creates a new Category" do
            expect do
              post :create, params: { category: valid_attributes }
            end.to change(Category, :count).by(1)
          end

          it "redirects to the created category" do
            post :create, params: { category: valid_attributes }
            expect(response).to redirect_to(Category.last)
          end
        end

        context "with invalid params" do
          it "returns a success response ('new' template)" do
            post :create, params: { category: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          post :create, params: { category: valid_attributes }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "PUT #update" do
    let(:new_attributes) { { name: "New Name" } }

    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        context "with valid params" do
          it "updates the requested category" do
            category = Fabricate(:category)
            expect do
              put :update, params: { id: category.to_param,
                                     category: new_attributes }
              category.reload
            end.to change(category, :name).to("New Name")
          end

          it "redirects to the category" do
            category = Fabricate(:category)
            put :update, params: { id: category.to_param,
                                   category: new_attributes }
            expect(response).to redirect_to(categories_url)
          end
        end

        context "with invalid params" do
          it "returns a success response ('edit' template)" do
            category = Fabricate(:category)
            put :update, params: { id: category.to_param,
                                   category: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          post :create, params: { category: new_attributes }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "for an admin" do
      let(:admin) { Fabricate(:user_admin) }

      before { sign_in(admin) }

      it "destroys the requested category" do
        category = Fabricate(:category)
        expect do
          delete :destroy, params: { id: category.to_param }
        end.to change(Category, :count).by(-1)
      end

      it "redirects to the categories list" do
        category = Fabricate(:category)
        delete :destroy, params: { id: category.to_param }
        expect(response).to redirect_to(categories_url)
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        it "doesn't destroy the requested category" do
          category = Fabricate(:category)
          expect do
            delete :destroy, params: { id: category.to_param }
          end.not_to change(Category, :count)
        end

        it "should be unauthorized" do
          category = Fabricate(:category)
          delete :destroy, params: { id: category.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
