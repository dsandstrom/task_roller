# frozen_string_literal: true

class OpenRepoIssueJob < RepoIssueJob
  def perform(*)
    super
    return unless issue && octokit

    octokit.add_comment github_repo_id, github_number,
                        issue.github_open_message(url)
  end
end
