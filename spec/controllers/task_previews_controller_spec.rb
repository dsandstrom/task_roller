require "rails_helper"

RSpec.describe TaskPreviewsController, type: :controller do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue) { Fabricate(:issue, project: project) }

  describe "GET #index" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type.downcase}")) }

        context "when html request" do
          it "returns a success response" do
            get :index, params: { issue_id: issue.to_param }
            expect(response).to be_successful
          end
        end

        context "when turbo_stream request" do
          it "returns a success response" do
            get :index, params: { issue_id: issue.to_param }, as: :turbo_stream
            expect(response).to be_successful
          end
        end
      end
    end
  end
end
