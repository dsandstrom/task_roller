# frozen_string_literal: true

require "rails_helper"

RSpec.describe RepositionIssueTypesController, type: :controller do
  let(:valid_attributes) { "up" }
  let(:invalid_attributes) { "" }

  describe "PUT #update" do
    before { Fabricate(:issue_type) }

    context "for an admin" do
      before { login(Fabricate(:user_admin)) }

      context "with valid params" do
        it "updates the requested issue_type's position" do
          issue_type = Fabricate(:issue_type)
          expect do
            put :update, params: { id: issue_type.to_param,
                                   sort: valid_attributes }
            issue_type.reload
          end.to change(issue_type, :position).from(2).to(1)
        end

        it "redirects to the issue_type list" do
          issue_type = Fabricate(:issue_type)
          put :update, params: { id: issue_type.to_param,
                                 sort: valid_attributes }
          expect(response).to redirect_to(roller_types_url)
        end
      end

      context "with invalid params" do
        it "doesn't update the requested issue_type" do
          issue_type = Fabricate(:issue_type)
          expect do
            put :update, params: { id: issue_type.to_param,
                                   sort: invalid_attributes }
            issue_type.reload
          end.not_to change(issue_type, :position)
        end

        it "redirects to the issue_type list" do
          issue_type = Fabricate(:issue_type)
          put :update, params: { id: issue_type.to_param,
                                 sort: invalid_attributes }
          expect(response).to redirect_to(roller_types_url)
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "redirects to unauthorized" do
          issue_type = Fabricate(:issue_type)
          put :update, params: { id: issue_type.to_param,
                                 sort: valid_attributes }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
