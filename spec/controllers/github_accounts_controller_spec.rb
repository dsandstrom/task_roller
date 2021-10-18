# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubAccountsController, type: :controller do
  describe "DELETE #destroy" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

      context "for a #{employee_type}" do
        context "with valid GithubAccount" do
          before do
            current_user.update github_id: 1234, github_username: "username"
          end

          before { sign_in(current_user) }

          it "clears current user's github_id" do
            expect do
              delete :destroy
              current_user.reload
            end.to change(current_user, :github_id).to(nil)
          end

          it "returns a success response" do
            delete :destroy
            expect(response).to redirect_to(edit_user_url(current_user))
          end
        end

        context "without a GithubAccount" do
          before do
            current_user.update github_id: nil, github_username: nil
          end

          before { sign_in(current_user) }

          it "doesn't change current user's github_id" do
            expect do
              delete :destroy
              current_user.reload
            end.not_to change(current_user, :github_id)
          end

          it "returns a success response" do
            delete :destroy
            expect(response).to redirect_to(edit_user_url(current_user))
          end
        end
      end
    end
  end
end
