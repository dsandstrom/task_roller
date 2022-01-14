# frozen_string_literal: true

class RepoIssueJob < ApplicationJob
  queue_as :default

  attr_accessor :issue

  def octokit
    @octokit ||= issue&.octokit
  end

  def github_repo_id
    @github_repo_id ||= issue&.github_repo_id
  end

  def github_id
    @github_id ||= issue&.github_id
  end

  def github_number
    @github_number ||= issue&.github_number
  end

  def perform(issue)
    self.issue = issue
  end
end
