# frozen_string_literal: true

require "rails_helper"

RSpec.describe SubscribedTasksController, type: :controller do
  let(:task) { Fabricate(:task) }
  let(:random_user) { Fabricate(:user_worker) }

  describe "GET #index" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { login(current_user) }

        it "returns a success response" do
          Fabricate(:task_subscription, task: task, user: current_user)
          get :index
          expect(response).to be_successful
        end
      end
    end
  end
end
