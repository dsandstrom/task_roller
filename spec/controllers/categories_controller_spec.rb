# frozen_string_literal: true

require "rails_helper"

RSpec.describe CategoriesController, type: :controller do
  let(:invalid_attributes) { { name: "" } }

  describe "GET #index" do
    it "returns a success response" do
      _category = Fabricate(:category)
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      category = Fabricate(:category)
      get :show, params: { id: category.to_param }
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns a success response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      category = Fabricate(:category)
      get :edit, params: { id: category.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    let(:valid_attributes) { { name: "Category Name" } }

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
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { category: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: "New Name" } }

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
        expect(response).to redirect_to(category)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        category = Fabricate(:category)
        put :update, params: { id: category.to_param,
                               category: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
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
end
