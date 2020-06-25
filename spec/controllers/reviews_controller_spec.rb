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
    it "returns a success response" do
      _review = Fabricate(:review, task: task)
      get :index, params: { task_id: task.to_param }
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: { task_id: task.to_param }
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      review = Fabricate(:review, task: task)
      get :edit, params: { task_id: task.to_param, id: review.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Review" do
        expect do
          post :create, params: { task_id: task.to_param,
                                  review: valid_attributes }
        end.to change(Review, :count).by(1)
      end

      it "redirects to the task" do
        post :create, params: { task_id: task.to_param,
                                review: valid_attributes }
        expect(response)
          .to redirect_to(category_project_task_path(category, project, task))
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { task_id: task.to_param,
                                review: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #approve" do
    context "with valid params" do
      it "updates the requested review" do
        review = Fabricate(:review, task: task)
        expect do
          put :approve, params: { task_id: task.to_param, id: review.to_param }
          review.reload
        end.to change(review, :approved).to(true)
      end

      it "redirects to the review" do
        review = Fabricate(:review, task: task)
        put :approve, params: { task_id: task.to_param, id: review.to_param }
        expect(response)
          .to redirect_to(category_project_task_path(category, project, task))
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        other_review = Fabricate(:disapproved_review, task: task)
        review = Fabricate(:review, task: task)
        # make review invalid
        other_review.update_attribute :approved, true

        put :approve, params: { task_id: task.to_param, id: review.to_param }
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #disapprove" do
    context "with valid params" do
      it "updates the requested review" do
        review = Fabricate(:review, task: task)
        expect do
          put :disapprove, params: { task_id: task.to_param,
                                     id: review.to_param }
          review.reload
        end.to change(review, :approved).to(false)
      end

      it "redirects to the review" do
        review = Fabricate(:review, task: task)
        put :disapprove, params: { task_id: task.to_param, id: review.to_param }
        expect(response)
          .to redirect_to(category_project_task_path(category, project, task))
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        other_review = Fabricate(:disapproved_review, task: task)
        review = Fabricate(:review, task: task)
        # make review invalid
        other_review.update_attribute :approved, true

        put :disapprove, params: { task_id: task.to_param, id: review.to_param }
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested review" do
      review = Fabricate(:review, task: task)
      expect do
        delete :destroy, params: { task_id: task.to_param, id: review.to_param }
      end.to change(Review, :count).by(-1)
    end

    it "redirects to the reviews list" do
      review = Fabricate(:review, task: task)
      delete :destroy, params: { task_id: task.to_param, id: review.to_param }
      expect(response)
        .to redirect_to(category_project_task_path(category, project, task))
    end
  end
end
