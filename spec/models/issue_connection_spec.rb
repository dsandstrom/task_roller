# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueConnection, type: :model do
  let(:project) { Fabricate(:project) }
  let(:source) { Fabricate(:issue, project: project) }
  let(:target) { Fabricate(:issue, project: project) }
  let(:user) { Fabricate(:user_reviewer) }

  before do
    @issue_connection =
      IssueConnection.new(source_id: source.id, target_id: target.id,
                          user_id: user.id)
  end

  subject { @issue_connection }

  it { is_expected.to respond_to(:source_id) }
  it { is_expected.to respond_to(:target_id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:scheme) }

  it { is_expected.to be_valid }

  it { is_expected.to validate_presence_of(:source_id) }
  it { is_expected.to validate_presence_of(:target_id) }
  it { is_expected.to validate_presence_of(:user_id) }

  it { is_expected.to belong_to(:source) }
  it { is_expected.to belong_to(:target) }
  it { is_expected.to respond_to(:user) }

  describe "#target_options" do
    let(:source) { Fabricate(:issue) }
    let(:issue_connection) do
      Fabricate.build(:issue_connection, source: source)
    end

    context "when source has a project" do
      context "with other issues" do
        it "returns source project's other issues" do
          issue = Fabricate(:issue, project: source.project)
          expect(issue_connection.target_options).to eq([issue])
        end
      end

      context "with no other issues" do
        it "returns source project's other issues" do
          expect(issue_connection.target_options).to eq([])
        end
      end
    end

    context "when source doesn't have a project" do
      before { issue_connection.source.project = nil }

      it "returns nil" do
        expect(issue_connection.target_options).to be_nil
      end
    end

    context "when source nil" do
      before { issue_connection.source = nil }

      it "returns nil" do
        expect(issue_connection.target_options).to be_nil
      end
    end

    context "when source id is nil" do
      before { issue_connection.source.id = nil }

      it "returns nil" do
        expect(issue_connection.target_options).to be_nil
      end
    end
  end

  describe "#subscribe_user" do
    let(:user) { Fabricate(:user_reviewer) }
    let(:project) { Fabricate(:project) }

    context "when source and target issues" do
      let(:target) { Fabricate(:issue, project: project) }

      context "and source has a user" do
        let(:source) { Fabricate(:issue, project: project, user: user) }

        let(:issue_connection) do
          Fabricate(:issue_connection, source: source, target: target)
        end

        context "that is not subscribed" do
          it "creates a issue_subscription for the issue user" do
            expect do
              issue_connection.subscribe_user
            end.to change(user.issue_subscriptions, :count).by(1)
          end

          it "creates only 1 IssueSubscription" do
            expect do
              issue_connection.subscribe_user
            end.to change(IssueSubscription, :count).by(1)
          end
        end

        context "that is already subscribed" do
          before do
            Fabricate(:issue_subscription, issue: target, user: user)
          end

          it "doesn't create a issue_subscription" do
            expect do
              issue_connection.subscribe_user
            end.not_to change(IssueSubscription, :count)
          end
        end
      end

      context "and source doesn't have a user" do
        let(:source) { Fabricate.build(:issue, project: project) }

        let(:issue_connection) do
          Fabricate.build(:issue_connection, source: source, target: target)
        end

        it "doesn't create a issue_subscription" do
          expect do
            issue_connection.subscribe_user
          end.not_to change(IssueSubscription, :count)
        end
      end
    end

    context "when no target issue" do
      let(:issue_connection) do
        Fabricate.build(:issue_connection, source: source, target: nil)
      end

      it "doesn't create a issue_subscription for the issue user" do
        expect do
          issue_connection.subscribe_user
        end.not_to change(IssueSubscription, :count)
      end
    end

    context "when no source issue" do
      let(:issue_connection) do
        Fabricate.build(:issue_connection, source: nil, target: target)
      end

      it "doesn't create a issue_subscription for the issue user" do
        expect do
          issue_connection.subscribe_user
        end.not_to change(IssueSubscription, :count)
      end
    end
  end

  describe "#validate" do
    describe "#target_has_options" do
      context "when source's project has other issues" do
        it { expect(subject).to be_valid }
      end

      context "when source's project has no other issues" do
        before { allow(subject).to receive(:target_options) { nil } }

        it { expect(subject).not_to be_valid }
      end
    end

    describe "#matching_projects" do
      context "when source and target have the same project" do
        it { expect(subject).to be_valid }
      end

      context "when source and target don't have the same project" do
        before { subject.target.project = Fabricate(:project) }

        it { expect(subject).not_to be_valid }
      end

      context "when source and target don't projects" do
        before do
          subject.source.project = nil
          subject.target.project = nil
        end

        it { expect(subject).not_to be_valid }
      end

      context "when source blank" do
        before { subject.source = nil }

        it { expect(subject).not_to be_valid }
      end

      context "when target blank" do
        before { subject.target = nil }

        it { expect(subject).not_to be_valid }
      end
    end
  end
end
