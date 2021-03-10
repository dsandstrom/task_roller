# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/issue_mailer
class IssueMailerPreview < ActionMailer::Preview
  def status_change
    IssueMailer.with(issue: Issue.first, user: User.first).status_change
  end
end
