# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueNotification, type: :model do
  let(:issue) { Fabricate(:issue) }
  let(:user) { Fabricate(:user_reporter) }

  before do
    @issue_notification = IssueNotification.new(issue_id: issue.id,
                                                user_id: user.id, event: "new")
  end

  subject { @issue_notification }

  it { is_expected.to be_valid }

  it { is_expected.to respond_to(:issue_id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:issue_comment_id) }
  it { is_expected.to respond_to(:event) }
  it { is_expected.to respond_to(:details) }

  it { is_expected.to validate_presence_of(:issue_id) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_length_of(:details).is_at_most(100) }

  describe "#event" do
    context "when a valid value" do
      %w[new comment status].each do |value|
        before { subject.event = value }

        it { is_expected.to be_valid }
      end
    end

    context "when an invalid value" do
      ["notnew", nil, ""].each do |value|
        before { subject.event = value }

        it { is_expected.not_to be_valid }
      end
    end
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:issue) }
  it { is_expected.to belong_to(:issue_comment) }

  describe "#send_email" do
    context "for a status change" do
      context "when details is blank" do
        let(:issue_notification) do
          Fabricate(:issue_status_notification, issue: issue, user: user,
                                                details: nil)
        end

        it "doesn't enqueue email" do
          expect do
            issue_notification.send_email
          end.not_to have_enqueued_job
        end
      end

      context "when details is 'old,new'" do
        let(:issue_notification) do
          Fabricate(:issue_status_notification, issue: issue, user: user,
                                                details: "old,new")
        end

        it "enqueues email" do
          expect do
            issue_notification.send_email
          end.to have_enqueued_job.on_queue("mailers").with(
            "IssueMailer", "status", "deliver_now",
            args: [], params: { issue: issue, user: user, old_status: "old",
                                new_status: "new" }
          )
        end
      end
    end

    context "for a new issue" do
      let(:issue_notification) do
        Fabricate(:issue_new_notification, issue: issue, user: user)
      end

      it "enqueues email" do
        expect do
          issue_notification.send_email
        end.to have_enqueued_job.on_queue("mailers").with(
          "IssueMailer", "new", "deliver_now",
          args: [], params: { issue: issue, user: user }
        )
      end
    end

    context "for a new comment" do
      let(:comment) { Fabricate(:issue_comment, issue: issue) }

      let(:issue_notification) do
        Fabricate(:issue_comment_notification, issue: issue, user: user,
                                               issue_comment: comment)
      end

      it "enqueues email" do
        expect do
          issue_notification.send_email
        end.to have_enqueued_job.on_queue("mailers").with(
          "IssueMailer", "comment", "deliver_now",
          args: [], params: { issue: issue, user: user, comment: comment }
        )
      end
    end

    context "for an invalid event" do
      let(:issue_notification) do
        Fabricate(:issue_notification, issue: issue, user: user)
      end

      before { issue_notification.update_column :event, "invalid" }

      it "doesn't enqueue email" do
        expect do
          issue_notification.send_email
        end.not_to have_enqueued_job
      end
    end

    context "for an invalid comment" do
      let(:issue_notification) do
        Fabricate(:issue_comment_notification, issue: issue, user: user,
                                               issue_comment: nil)
      end

      it "doesn't enqueue email" do
        expect do
          issue_notification.send_email
        end.not_to have_enqueued_job
      end
    end
  end
end
