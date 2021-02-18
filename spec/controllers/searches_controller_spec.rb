# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchesController, type: :controller do
  describe "GET #new" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        it "returns a success response" do
          get :new
          expect(response).to be_successful
        end
      end
    end
  end

  describe "GET #index" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when filters" do
          it "returns a success response" do
            get :index, params: { query: "test", order: "updated,desc" }
            expect(response).to be_successful
          end
        end

        context "when no filters" do
          it "redirects to new" do
            get :index
            expect(response).to redirect_to(:search)
          end
        end
      end
    end
  end
end
