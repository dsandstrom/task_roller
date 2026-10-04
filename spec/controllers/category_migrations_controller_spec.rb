require "rails_helper"

RSpec.describe CategoryMigrationsController, type: :controller do
  before do
    Fabricate(:issue_type)
    Fabricate(:task_type)
  end

  describe "GET #index" do
    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when categories" do
          before do
            Fabricate(:category)
          end

          it "returns a success response" do
            get :index

            expect(response).to be_successful
          end
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before do
          Fabricate(:category)
          sign_in(current_user)
        end

        it "should be unauthorized" do
          get :index

          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "GET #new" do
    let(:category) { Fabricate(:category) }

    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when another category" do
          before do
            Fabricate(:category)
          end

          it "returns a success response" do
            get :new, params: { category_id: category.id }

            expect(response).to be_successful
          end
        end

        context "when no other categories" do
          it "redirects to root" do
            get :new, params: { category_id: category.id }

            expect(response).to redirect_to(:root)
          end
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        it "should be unauthorized" do
          get :new, params: { category_id: category.id }

          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "POST #create" do
    let!(:category) { Fabricate(:category) }
    let!(:new_category) { Fabricate(:category) }
    let!(:project) { Fabricate(:project, category: category) }

    let(:valid_params) { { migration_id: new_category.to_param } }
    let(:invalid_params) { { migration_id: "" } }

    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when current category has a project" do
          context "when valid params" do
            it "updates the project's category" do
              expect do
                post :create, params: { category_id: category.id,
                                        category: valid_params }
                project.reload
              end.to change(project, :category_id).to(new_category.id)
            end

            it "redirects to root" do
              post :create, params: { category_id: category.id,
                                      category: valid_params }

              expect(response).to redirect_to(:root)
            end
          end

          context "when invalid params" do
            it "doesn't update the project" do
              expect do
                post :create, params: { category_id: category.id,
                                        category: invalid_params }
                project.reload
              end.not_to change(project, :category_id)
            end

            it "returns a success response" do
              post :create, params: { category_id: category.id,
                                      category: invalid_params }

              expect(response).to be_successful
            end
          end
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        it "doesn't update the project" do
          expect do
            post :create, params: { category_id: category.id,
                                    category: valid_params }
            project.reload
          end.not_to change(project, :category_id)
        end

        it "should be unauthorized" do
          post :create, params: { category_id: category.id,
                                  category: valid_params }

          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
