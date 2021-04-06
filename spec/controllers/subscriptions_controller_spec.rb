# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubscriptionsController, type: :controller do
  describe "GET #index" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before do
          sign_in(current_user)
          Fabricate(:issue_subscription, user: current_user)
          Fabricate(:task_subscription, user: current_user)
        end

        context "when type is nil" do
          it "returns a success response" do
            get :index
            expect(response).to be_successful
          end
        end

        context "when type is 'issues'" do
          it "returns a success response" do
            get :index, params: { type: "issues" }
            expect(response).to be_successful
          end
        end

        context "when type is 'tasks'" do
          it "returns a success response" do
            get :index, params: { type: "tasks" }
            expect(response).to be_successful
          end
        end
      end
    end
  end
end
