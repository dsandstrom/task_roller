# frozen_string_literal: true

class CloseRepoIssueJob < RepoIssueJob
  def perform(*)
    super
    return unless issue && octokit

    octokit.close_issue github_repo_id, github_number
    octokit.add_comment github_repo_id, github_number,
                        issue.github_close_message
  end
end
