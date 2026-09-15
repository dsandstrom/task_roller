class IssueComment < ApplicationRecord
  validates :body, presence: true

  belongs_to :issue, inverse_of: :comments
  belongs_to :user
  has_many :notifications, class_name: 'IssueNotification', dependent: :destroy
  has_many :issue_branches, class_name: 'IssueBranch', dependent: :nullify,
                            inverse_of: :issue_comment
  has_many :task_branches, class_name: 'TaskBranch', dependent: :nullify,
                           inverse_of: :issue_comment

  default_scope { order(created_at: :asc) }

  def subscribe_user
    return unless issue && user

    issue.subscribe_user(user)
  end

  def body_html
    @body_html ||= RollerMarkdown.new.render(body) || ''
  end

  def notify_subscribers
    issue&.notify_of_comment(self)
  end
end
