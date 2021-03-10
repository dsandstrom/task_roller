# frozen_string_literal: true

require "rails_helper"

RSpec.describe IssueMailer, type: :mailer do
  let(:issue) { Fabricate(:issue) }
  let(:user) { Fabricate(:user) }

  describe "#status_change" do
    let(:mail) do
      IssueMailer.with(issue: issue, user: user, old_status: "closed")
                 .status_change
    end

    it "renders the headers" do
      expect(mail.from).to eq(["noreply@task-roller.net"])
      expect(mail.to).to eq([user.email])
      expect(mail.subject).to eq("Task Roller Update for Issue##{issue.id}")
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Issue##{issue.id}")
      expect(mail.body.encoded).to have_link(nil, href: issue_url(issue))
    end
  end
end
