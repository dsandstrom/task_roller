# frozen_string_literal: true

require "rails_helper"

RSpec.describe RollerTypesController, type: :controller do
  describe "GET #index" do
    context "for an admin" do
      before { login(Fabricate(:user_admin)) }

      it "returns a success response" do
        Fabricate(:issue_type)
        Fabricate(:task_type)
        get :index, params: {}
        expect(response).to be_successful
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "unauthorized" do
          Fabricate(:issue_type)
          Fabricate(:task_type)
          get :index, params: {}
          expect(response).to redirect_to :root
        end
      end
    end
  end
end
