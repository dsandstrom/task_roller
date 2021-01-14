# frozen_string_literal: true

require "rails_helper"

RSpec.describe StaticController, type: :controller do
  describe "GET #unauthorized" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        it "returns a success response" do
          get :unauthorized
          expect(response).to be_successful
        end
      end
    end
  end

  describe "GET #sitemap" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        it "returns a success response" do
          get :sitemap
          expect(response).to be_successful
        end
      end
    end
  end
end
