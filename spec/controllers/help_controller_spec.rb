# frozen_string_literal: true

require "rails_helper"

RSpec.describe HelpController, type: :controller do
  describe "GET #index" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        it "returns a success response" do
          get :index
          expect(response).to be_successful
        end
      end
    end
  end

  describe "GET #issue_types" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        it "returns a success response" do
          get :issue_types
          expect(response).to be_successful
        end
      end
    end
  end

  describe "GET #user_types" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        it "returns a success response" do
          get :user_types
          expect(response).to be_successful
        end
      end
    end
  end

  describe "GET #workflows" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        it "returns a success response" do
          get :workflows
          expect(response).to be_successful
        end
      end
    end
  end
end
