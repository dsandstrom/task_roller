require "rails_helper"

RSpec.describe RepositionProjectsController, type: :controller do
  describe "PUT #update" do
    let(:category) { Fabricate(:category) }
    let(:project) { Fabricate(:project, category: category) }

    let(:valid_attributes) { { new_position: 1 } }
    let(:invalid_attributes) { { new_position: "" } }

    before do
      Fabricate(:project)
      Fabricate(:project, category: category)
    end

    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type}")) }

        context "with valid params" do
          context "for html request" do
            it "updates the requested project's position" do
              expect do
                put :update, params: { id: project.to_param,
                                       project: valid_attributes }
                project.reload
              end.to change(project, :position).from(2).to(1)
            end

            it "redirects to the project list" do
              put :update, params: { id: project.to_param,
                                     project: valid_attributes }
              expect(response).to redirect_to(reposition_categories_path)
            end
          end

          context "for json request" do
            it "updates the requested project's position" do
              expect do
                put :update, params: { id: project.to_param,
                                       project: valid_attributes },
                             as: :json
                project.reload
              end.to change(project, :position).from(2).to(1)
            end

            it "responds with ok" do
              put :update, params: { id: project.to_param,
                                     project: valid_attributes },
                           as: :json
              expect(response).to have_http_status(:ok)
            end
          end
        end

        context "with invalid params" do
          context "for html request" do
            it "doesn't update the requested project" do
              expect do
                put :update, params: { id: project.to_param,
                                       project: invalid_attributes }
                project.reload
              end.not_to change(project, :position)
            end

            it "redirects to the project list" do
              put :update, params: { id: project.to_param,
                                     project: invalid_attributes }
              expect(response).to redirect_to(reposition_categories_path)
            end
          end

          context "for json request" do
            it "doesn't update the requested project" do
              expect do
                put :update, params: { id: project.to_param,
                                       project: invalid_attributes },
                             as: :json
                project.reload
              end.not_to change(project, :position)
            end

            it "responds with unprocessable_content" do
              put :update, params: { id: project.to_param,
                                     project: invalid_attributes },
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
            put :update, params: { id: project.to_param,
                                   project: valid_attributes }
            expect_to_be_unauthorized(response)
          end
        end

        context "for json request" do
          it "redirects to unauthorized" do
            put :update, params: { id: project.to_param,
                                   project: valid_attributes },
                         as: :json
            expect_to_be_forbidden(response)
          end
        end
      end
    end
  end
end
