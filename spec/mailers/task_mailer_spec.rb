# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskMailer, type: :mailer do
  let(:task) { Fabricate(:task) }
  let(:user) { Fabricate(:user) }
  let(:comment) { Fabricate(:task_comment, task: task) }

  describe "#status" do
    let(:options) do
      { task: task, user: user, old_status: "closed", new_status: "open" }
    end

    let(:mail) do
      TaskMailer.with(options).status
    end

    it "renders the headers" do
      expect(mail.from).to eq(["noreply@task-roller.net"])
      expect(mail.to).to eq([user.email])
      expect(mail.subject).to eq("Task Roller: Update for Task##{task.id}")
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Task##{task.id}")
      expect(mail.body.encoded).to have_link(nil, href: task_url(task))
    end
  end

  describe "#comment" do
    let(:mail) do
      TaskMailer.with(task: task, user: user, comment: comment).comment
    end

    it "renders the headers" do
      expect(mail.from).to eq(["noreply@task-roller.net"])
      expect(mail.to).to eq([user.email])
      expect(mail.subject).to eq("Task Roller: Comment for Task##{task.id}")
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Task##{task.id}")
      url = task_url(task, anchor: "comment-#{comment.id}")
      expect(mail.body.encoded).to have_link(nil, href: url)
    end
  end

  describe "#new" do
    let(:mail) do
      TaskMailer.with(task: task, user: user).new
    end

    it "renders the headers" do
      expect(mail.from).to eq(["noreply@task-roller.net"])
      expect(mail.to).to eq([user.email])
      expect(mail.subject).to eq("Task Roller: New Task##{task.id}")
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Task##{task.id}")
      expect(mail.body.encoded).to have_link(nil, href: task_url(task))
    end
  end
end
