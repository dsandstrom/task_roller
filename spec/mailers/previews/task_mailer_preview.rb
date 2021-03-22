# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/task_mailer
class TaskMailerPreview < ActionMailer::Preview
  def status
    options = { task: Task.joins(:user).first, user: User.first,
                old_status: 'closed', new_status: 'open' }
    TaskMailer.with(options).status
  end

  def comment
    options = { task: Task.joins(:user).last, user: User.last,
                comment: TaskComment.joins(:user).last }
    TaskMailer.with(options).comment
  end

  def new
    options = { task: Task.all[-2], user: User.all[-2] }
    TaskMailer.with(options).new
  end
end
