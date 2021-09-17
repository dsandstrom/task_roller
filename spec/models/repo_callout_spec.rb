# frozen_string_literal: true

require "rails_helper"

RSpec.describe RepoCallout, type: :model do
  let(:user) { Fabricate(:user) }
  let(:task) { Fabricate(:task) }

  before do
    @repo_callout =
      RepoCallout.new(task_id: task.id, user_id: user.id, action: "complete",
                      commit_sha: "zzzyyyxxxx", commit_message: "Fixes #12")
  end

  subject { @repo_callout }

  it { is_expected.to be_valid }

  it { is_expected.to respond_to(:github_commit_id) }
  it { is_expected.to respond_to(:commit_html_url) }

  it { is_expected.to validate_presence_of(:task_id) }
  it { is_expected.to validate_presence_of(:action) }
  it { is_expected.to validate_presence_of(:commit_sha) }
  it { is_expected.to validate_presence_of(:commit_message) }

  it { is_expected.to validate_uniqueness_of(:task_id).scoped_to(:commit_sha) }

  it do
    is_expected.to validate_inclusion_of(:action)
      .in_array(%w[start pause complete])
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:task) }
end
