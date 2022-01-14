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

  def url
    @url ||= build_url
  end

  private

    def build_url
      host = Rails.application.config.action_mailer.default_url_options[:host]
      Rails.application.routes.url_helpers.issue_url(issue, host: host)
    end
end
