require "rails_helper"

RSpec.describe RepositionTaskTypesController, type: :controller do
  let(:valid_attributes) { { new_position: "1" } }
  let(:invalid_attributes) { { new_position: "" } }

  describe "PATCH #update" do
    before { Fabricate(:task_type) }

    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let!(:task_type) { Fabricate(:task_type) }

        before { sign_in(Fabricate("user_#{employee_type}")) }

        context "with valid params" do
          context "for html request" do
            it "updates the requested task_type's position" do
              expect do
                patch :update, params: { id: task_type.to_param,
                                         task_type: valid_attributes }
                task_type.reload
              end.to change(task_type, :position).from(2).to(1)
            end

            it "redirects to the task_type list" do
              patch :update, params: { id: task_type.to_param,
                                       task_type: valid_attributes }
              expect(response).to redirect_to(issue_types_url)
            end
          end

          context "for json request" do
            it "updates the requested task_type's position" do
              expect do
                patch :update, params: { id: task_type.to_param,
                                         task_type: valid_attributes },
                               as: :json
                task_type.reload
              end.to change(task_type, :position).from(2).to(1)
            end

            it "redirects to the task_type list" do
              patch :update, params: { id: task_type.to_param,
                                       task_type: valid_attributes },
                             as: :json
              expect(response).to have_http_status(:ok)
            end
          end
        end

        context "with invalid params" do
          context "for html request" do
            it "doesn't update the requested task_type" do
              expect do
                patch :update, params: { id: task_type.to_param,
                                         task_type: invalid_attributes }
                task_type.reload
              end.not_to change(task_type, :position)
            end

            it "redirects to the task_type list" do
              patch :update, params: { id: task_type.to_param,
                                       task_type: invalid_attributes }
              expect(response).to redirect_to(issue_types_url)
            end
          end

          context "for json request" do
            it "doesn't update the requested task_type" do
              expect do
                patch :update, params: { id: task_type.to_param,
                                         task_type: invalid_attributes },
                               as: :json
                task_type.reload
              end.not_to change(task_type, :position)
            end

            it "redirects to the task_type list" do
              patch :update, params: { id: task_type.to_param,
                                       task_type: invalid_attributes },
                             as: :json
              expect(response).to have_http_status(:unprocessable_content)
            end
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let!(:task_type) { Fabricate(:task_type) }

        before { sign_in(Fabricate("user_#{employee_type}")) }

        context "for html request" do
          it "redirects to unauthorized" do
            patch :update, params: { id: task_type.to_param,
                                     task_type: valid_attributes }
            expect_to_be_unauthorized(response)
          end
        end

        context "for json request" do
          it "redirects to unauthorized" do
            patch :update, params: { id: task_type.to_param,
                                     task_type: valid_attributes },
                           as: :json
            expect_to_be_forbidden(response)
          end
        end
      end
    end
  end
end
