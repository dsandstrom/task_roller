# frozen_string_literal: true

require "rails_helper"

RSpec.describe OpenRepoIssueJob, type: :job do
  let(:issue) { Fabricate(:issue) }

  describe "#perform" do
    after { ENV["GITHUB_USER_TOKEN"] = nil }

    context "when valid issue" do
      it "sends API request with a comment" do
        ENV["GITHUB_USER_TOKEN"] = "token"
        api_url = "https://api.github.com/repositories/27/issues/5/comments"
        issue.update github_repo_id: 27, github_id: 11, github_number: 5

        stub_request(:post, api_url)

        OpenRepoIssueJob.perform_now issue
        expect(a_request(:post, api_url)).to have_been_made.once
      end
    end

    context "when issue is missing a github_id" do
      it "sends API request with a comment" do
        ENV["GITHUB_USER_TOKEN"] = "token"
        api_url = "https://api.github.com/repositories/27/issues/5/comments"
        issue.update github_repo_id: 27, github_id: nil, github_number: 5

        stub_request(:post, api_url)

        OpenRepoIssueJob.perform_now issue
        expect(a_request(:post, api_url)).not_to have_been_made
      end
    end

    context "when issue is missing a github_repo_id" do
      it "sends API request with a comment" do
        ENV["GITHUB_USER_TOKEN"] = "token"
        api_url = "https://api.github.com/repositories/27/issues/5/comments"
        issue.update github_repo_id: nil, github_id: 11, github_number: 5

        stub_request(:post, api_url)

        OpenRepoIssueJob.perform_now issue
        expect(a_request(:post, api_url)).not_to have_been_made
      end
    end

    context "when issue is missing a github_number" do
      it "sends API request with a comment" do
        ENV["GITHUB_USER_TOKEN"] = "token"
        api_url = "https://api.github.com/repositories/27/issues/5/comments"
        issue.update github_repo_id: 27, github_id: 11, github_number: nil

        stub_request(:post, api_url)

        OpenRepoIssueJob.perform_now issue
        expect(a_request(:post, api_url)).not_to have_been_made
      end
    end
  end
end
