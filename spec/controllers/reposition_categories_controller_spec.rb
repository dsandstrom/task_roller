require "rails_helper"

RSpec.describe RepositionCategoriesController, type: :controller do
  describe "GET #index" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        it "renders successfully" do
          get :index
          expect(response).to be_successful
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        it "redirects to unauthorized" do
          put :index
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "PUT #update" do
    let(:valid_attributes) { { new_position: 1 } }
    let(:invalid_attributes) { { new_position: "" } }

    before { Fabricate(:category) }

    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        context "with valid params" do
          it "updates the requested category's position" do
            category = Fabricate(:category)
            expect do
              put :update, params: { id: category.to_param,
                                     category: valid_attributes }
              category.reload
            end.to change(category, :position).from(2).to(1)
          end

          it "redirects to the category list" do
            category = Fabricate(:category)
            put :update, params: { id: category.to_param,
                                   category: valid_attributes }
            expect(response).to redirect_to(reposition_categories_path)
          end
        end

        context "with invalid params" do
          it "doesn't update the requested category" do
            category = Fabricate(:category)
            expect do
              put :update, params: { id: category.to_param,
                                     category: invalid_attributes }
              category.reload
            end.not_to change(category, :position)
          end

          it "redirects to the category list" do
            category = Fabricate(:category)
            put :update, params: { id: category.to_param,
                                   category: invalid_attributes }
            expect(response).to redirect_to(reposition_categories_path)
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        it "redirects to unauthorized" do
          category = Fabricate(:category)
          put :update, params: { id: category.to_param,
                                 category: valid_attributes }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
