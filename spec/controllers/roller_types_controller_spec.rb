# frozen_string_literal: true

require "rails_helper"

RSpec.describe RollerTypesController, type: :controller do
  describe "GET #index" do
    it "returns a success response" do
      Fabricate(:issue_type)
      Fabricate(:task_type)
      get :index, params: {}
      expect(response).to be_success
    end
  end
end