# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/issue_mailer
class IssueMailerPreview < ActionMailer::Preview
  def status_change
    IssueMailer.with(issue: Issue.first, user: User.first, old_status: 'closed',
                     new_status: 'open')
               .status_change
  end

  def comment
    IssueMailer.with(issue: Issue.last, user: User.last,
                     comment: IssueComment.last)
               .comment
  end
end
