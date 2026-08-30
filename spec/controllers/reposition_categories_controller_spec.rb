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
          context "for html request" do
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

          context "for json request" do
            it "updates the requested category's position" do
              category = Fabricate(:category)
              expect do
                put :update, params: { id: category.to_param,
                                       category: valid_attributes },
                             as: :json
                category.reload
              end.to change(category, :position).from(2).to(1)
            end

            it "responds with ok" do
              category = Fabricate(:category)
              put :update, params: { id: category.to_param,
                                     category: valid_attributes },
                           as: :json
              expect(response).to have_http_status(:ok)
            end
          end
        end

        context "with invalid params" do
          context "for html request" do
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

          context "for json request" do
            it "doesn't update the requested category" do
              category = Fabricate(:category)
              expect do
                put :update, params: { id: category.to_param,
                                       category: invalid_attributes },
                             as: :json
                category.reload
              end.not_to change(category, :position)
            end

            it "responds with unprocessable_content" do
              category = Fabricate(:category)
              put :update, params: { id: category.to_param,
                                     category: invalid_attributes },
                           as: :json
              expect(response).to have_http_status(:unprocessable_content)
            end
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        context "for html request" do
          it "redirects to unauthorized" do
            category = Fabricate(:category)
            put :update, params: { id: category.to_param,
                                   category: valid_attributes }
            expect_to_be_unauthorized(response)
          end
        end

        context "for json request" do
          it "redirects to unauthorized" do
            category = Fabricate(:category)
            put :update, params: { id: category.to_param,
                                   category: valid_attributes },
                         as: :json
            expect_to_be_forbidden(response)
          end
        end
      end
    end
  end
end
