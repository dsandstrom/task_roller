# frozen_string_literal: true

require "rails_helper"

RSpec.describe RepositionTaskTypesController, type: :controller do
  let(:valid_attributes) { "up" }
  let(:invalid_attributes) { "" }

  before { login(Fabricate(:user_admin)) }

  describe "PUT #update" do
    before { Fabricate(:task_type) }

    context "with valid params" do
      it "updates the requested task_type's position" do
        task_type = Fabricate(:task_type)
        expect do
          put :update, params: { id: task_type.to_param,
                                 sort: valid_attributes }
          task_type.reload
        end.to change(task_type, :position).from(2).to(1)
      end

      it "redirects to the task_type list" do
        task_type = Fabricate(:task_type)
        put :update, params: { id: task_type.to_param,
                               sort: valid_attributes }
        expect(response).to redirect_to(roller_types_url)
      end
    end

    context "with invalid params" do
      it "doesn't update the requested task_type" do
        task_type = Fabricate(:task_type)
        expect do
          put :update, params: { id: task_type.to_param,
                                 sort: invalid_attributes }
          task_type.reload
        end.not_to change(task_type, :position)
      end

      it "redirects to the task_type list" do
        task_type = Fabricate(:task_type)
        put :update, params: { id: task_type.to_param,
                               sort: invalid_attributes }
        expect(response).to redirect_to(roller_types_url)
      end
    end
  end
end
