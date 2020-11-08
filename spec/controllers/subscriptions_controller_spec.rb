# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubscriptionsController, type: :controller do
  describe "GET #index" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { login(current_user) }

        context "when users" do
          it "returns a success response" do
            Fabricate(:issue, user: current_user)
            Fabricate(:task, user: current_user)
            Fabricate(:task_assignee, assignee: current_user)
            get :index
            expect(response).to be_successful
          end
        end
      end
    end
  end
end
