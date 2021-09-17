# frozen_string_literal: true

Fabricator(:repo_callout) do
  user
  task
  action { 'start' }
  commit_sha { sequence(:commit_sha) { |i| "abcd#{i}" } }
  github_commit_id { sequence(:github_commit_id) { |i| 1234 + i } }

  after_build do |repo_callout|
    repo_callout.commit_message = "Fixes Task##{repo_callout.task_id}"
    repo_callout.commit_html_url =
      "https://github.com/test/repo/commit/#{repo_callout.commit_sha}"
  end
end
