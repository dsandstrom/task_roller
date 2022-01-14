# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReopenRepoIssueJob, type: :job do
  let(:issue) do
    Fabricate(:issue, github_repo_id: 27, github_id: 11, github_number: 5)
  end

  let(:api_comment_url) do
    "https://api.github.com/repositories/27/issues/5/comments"
  end

  let(:api_action_url) do
    "https://api.github.com/repositories/27/issues/5"
  end

  describe "#perform" do
    before do
      stub_request(:post, api_comment_url)
      stub_request(:patch, api_action_url)
    end

    after { ENV["GITHUB_USER_TOKEN"] = nil }

    context "when valid issue" do
      before { ENV["GITHUB_USER_TOKEN"] = "token" }

      it "sends API request with a comment" do
        ReopenRepoIssueJob.perform_now issue
        expect(a_request(:post, api_comment_url)).to have_been_made.once
      end

      it "sends API request to reopen" do
        ReopenRepoIssueJob.perform_now issue
        expect(
          a_request(:patch, api_action_url).with(body: { state: "open" })
        ).to have_been_made.once
      end
    end

    context "when issue is missing a github_id" do
      before do
        ENV["GITHUB_USER_TOKEN"] = "token"
        issue.update github_id: nil
      end

      it "doesn't send API request with a comment" do
        ReopenRepoIssueJob.perform_now issue
        expect(a_request(:post, api_comment_url)).not_to have_been_made
      end

      it "doesn't send API request to reopen" do
        ReopenRepoIssueJob.perform_now issue
        expect(a_request(:patch, api_action_url)).not_to have_been_made.once
      end
    end

    context "when issue is missing a github_repo_id" do
      before do
        ENV["GITHUB_USER_TOKEN"] = "token"
        issue.update github_repo_id: nil
      end

      it "doesn't send API request with a comment" do
        ReopenRepoIssueJob.perform_now issue
        expect(a_request(:post, api_comment_url)).not_to have_been_made
      end

      it "doesn't send API request to reopen" do
        ReopenRepoIssueJob.perform_now issue
        expect(a_request(:patch, api_action_url)).not_to have_been_made.once
      end
    end

    context "when issue is missing a github_number" do
      before do
        ENV["GITHUB_USER_TOKEN"] = "token"
        issue.update github_number: nil
      end

      it "doesn't send API request with a comment" do
        ReopenRepoIssueJob.perform_now issue
        expect(a_request(:post, api_comment_url)).not_to have_been_made
      end

      it "doesn't send API request to reopen" do
        ReopenRepoIssueJob.perform_now issue
        expect(a_request(:patch, api_action_url)).not_to have_been_made.once
      end
    end

    context "when github token missing" do
      before { ENV["GITHUB_USER_TOKEN"] = nil }

      it "doesn't send API request with a comment" do
        ReopenRepoIssueJob.perform_now issue
        expect(a_request(:post, api_comment_url)).not_to have_been_made
      end

      it "doesn't send API request to reopen" do
        ReopenRepoIssueJob.perform_now issue
        expect(a_request(:patch, api_action_url)).not_to have_been_made.once
      end
    end
  end
end
