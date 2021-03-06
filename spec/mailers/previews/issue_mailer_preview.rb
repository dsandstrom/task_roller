# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/issue_mailer
class IssueMailerPreview < ActionMailer::Preview
  def status
    IssueMailer.with(issue: Issue.first, user: User.first, old_status: 'closed',
                     new_status: 'open')
               .status
  end

  def comment
    IssueMailer.with(issue: Issue.last, user: User.last,
                     comment: IssueComment.last)
               .comment
  end

  def new
    IssueMailer.with(issue: Issue.all[-2], user: User.all[-2]).new
  end
end
