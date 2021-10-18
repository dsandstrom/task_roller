# frozen_string_literal: true

require "rails_helper"

RSpec.describe GithubAccount, type: :model do
  let(:user) do
    Fabricate(:user_reporter, github_id: 4321, github_username: "username")
  end

  before do
    @github_account = GithubAccount.new(user)
  end

  subject { @github_account }

  it { is_expected.to respond_to(:remote_id) }
  it { is_expected.to respond_to(:username) }
  it { is_expected.to respond_to(:user) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to validate_presence_of(:remote_id) }
  it { is_expected.to validate_presence_of(:username) }

  describe "#user_id" do
    context "when user" do
      it "returns user.id" do
        expect(subject.user_id).to eq(user.id)
      end
    end

    context "when no user" do
      before { subject.user = nil }

      it "returns nil" do
        expect(subject.user_id).to be_nil
      end
    end
  end
end
