# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReviewsController, type: :controller do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:task) { Fabricate(:task, project: project) }
  let(:user_reviewer) { Fabricate(:user_reviewer) }

  let(:valid_attributes) do
    { user_id: user_reviewer.id }
  end

  let(:invalid_attributes) do
    { user_id: "" }
  end

  describe "GET #index" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type.downcase}")) }

        it "returns a success response" do
          _review = Fabricate(:review, task: task)
          get :index, params: { task_id: task.to_param }
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

        context "when progression task is assigned to them" do
          before { task.assignees << current_user }

          it "returns a success response" do
            get :new, params: { task_id: task.to_param }
            expect(response).to be_successful
          end
        end

        context "when progression task is not assigned to them" do
          it "should be unauthorized" do
            get :new, params: { task_id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "GET #edit" do
    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "returns a success response" do
          review = Fabricate(:review, task: task)
          get :edit, params: { task_id: task.to_param, id: review.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before do
          task.assignees << current_user
          login(current_user)
        end

        it "should be unauthorized" do
          review = Fabricate(:review, task: task)
          get :edit, params: { task_id: task.to_param, id: review.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "POST #create" do
    let(:path) { category_project_task_path(task.category, task.project, task) }

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { login(current_user) }

        context "when review task is assigned to them" do
          before { task.assignees << current_user }

          context "with valid params" do
            it "creates a new Review" do
              expect do
                post :create, params: { task_id: task.to_param }
              end.to change(current_user.reviews, :count).by(1)
            end

            it "redirects to the task" do
              post :create, params: { task_id: task.to_param }
              expect(response).to redirect_to(path)
            end
          end
        end

        context "when review task is not assigned to them" do
          it "doesn't create a new Review" do
            expect do
              post :create, params: { task_id: task.to_param }
            end.not_to change(Review, :count)
          end

          it "should be unauthorized" do
            post :create, params: { task_id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "destroys the requested review" do
          review = Fabricate(:review, task: task)
          expect do
            delete :destroy, params: { task_id: task.to_param,
                                       id: review.to_param }
          end.to change(Review, :count).by(-1)
        end

        it "redirects to the reviews list" do
          review = Fabricate(:review, task: task)
          delete :destroy, params: { task_id: task.to_param,
                                     id: review.to_param }
          url = category_project_task_path(category, project, task)
          expect(response).to redirect_to(url)
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "doesn't destroy the requested review" do
          review = Fabricate(:review, task: task)
          expect do
            delete :destroy, params: { task_id: task.to_param,
                                       id: review.to_param }
          end.not_to change(Review, :count)
        end

        it "should be unauthorized" do
          review = Fabricate(:review, task: task)
          delete :destroy, params: { task_id: task.to_param,
                                     id: review.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "PUT #approve" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "with valid params" do
          it "approves the requested review" do
            review = Fabricate(:pending_review, task: task)
            expect do
              put :approve, params: { task_id: task.to_param,
                                      id: review.to_param }
              review.reload
            end.to change(review, :approved).to(true)
          end

          it "updates the requested review's user_id" do
            review = Fabricate(:pending_review, task: task)
            expect do
              put :approve, params: { task_id: task.to_param,
                                      id: review.to_param }
              review.reload
            end.to change(review, :user_id).to(current_user.id)
          end

          it "redirects to the review" do
            review = Fabricate(:pending_review, task: task)
            put :approve, params: { task_id: task.to_param,
                                    id: review.to_param }
            url = category_project_task_path(category, project, task)
            expect(response).to redirect_to(url)
          end
        end

        context "with invalid params" do
          it "doesn't approve the requested review" do
            other_review = Fabricate(:disapproved_review, task: task)
            review = Fabricate(:pending_review, task: task)
            # make review invalid
            other_review.update_column :approved, true
            expect do
              put :approve, params: { task_id: task.to_param,
                                      id: review.to_param }
              review.reload
            end.not_to change(review, :approved)
          end

          it "returns a success response ('edit' template)" do
            other_review = Fabricate(:disapproved_review, task: task)
            review = Fabricate(:pending_review, task: task)
            # make review invalid
            other_review.update_column :approved, true

            put :approve, params: { task_id: task.to_param,
                                    id: review.to_param }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          review = Fabricate(:pending_review, task: task)
          put :approve, params: { task_id: task.to_param,
                                  id: review.to_param }
          expect_to_be_unauthorized(response)
        end

        it "shouldn't update the requested review" do
          review = Fabricate(:pending_review, task: task)
          expect do
            put :approve, params: { task_id: task.to_param,
                                    id: review.to_param }
            review.reload
          end.not_to change(review, :approved).from(nil)
        end
      end
    end
  end

  describe "PUT #disapprove" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "with valid params" do
          it "disapproves the requested review" do
            review = Fabricate(:pending_review, task: task)
            expect do
              put :disapprove, params: { task_id: task.to_param,
                                         id: review.to_param }
              review.reload
            end.to change(review, :approved).to(false)
          end

          it "updates the requested review's user_id" do
            review = Fabricate(:pending_review, task: task)
            expect do
              put :disapprove, params: { task_id: task.to_param,
                                         id: review.to_param }
              review.reload
            end.to change(review, :user_id).to(current_user.id)
          end

          it "redirects to the review" do
            review = Fabricate(:pending_review, task: task)
            put :disapprove, params: { task_id: task.to_param,
                                       id: review.to_param }
            url = category_project_task_path(category, project, task)
            expect(response).to redirect_to(url)
          end
        end

        context "with invalid params" do
          it "doesn't disapprove the requested review" do
            other_review = Fabricate(:disapproved_review, task: task)
            review = Fabricate(:pending_review, task: task)
            # make review invalid
            other_review.update_column :approved, true
            expect do
              put :disapprove, params: { task_id: task.to_param,
                                         id: review.to_param }
              review.reload
            end.not_to change(review, :approved).from(nil)
          end

          it "returns a success response ('edit' template)" do
            other_review = Fabricate(:disapproved_review, task: task)
            review = Fabricate(:pending_review, task: task)
            # make review invalid
            other_review.update_column :approved, true

            put :disapprove, params: { task_id: task.to_param,
                                       id: review.to_param }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "should be unauthorized" do
          review = Fabricate(:pending_review, task: task)
          put :disapprove, params: { task_id: task.to_param,
                                     id: review.to_param }
          expect_to_be_unauthorized(response)
        end

        it "shouldn't update the project" do
          review = Fabricate(:pending_review, task: task)
          expect do
            put :disapprove, params: { task_id: task.to_param,
                                       id: review.to_param }
            review.reload
          end.not_to change(review, :approved).from(nil)
        end
      end
    end
  end
end
