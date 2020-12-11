# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'Task Roller <noreply@task-roller.net>'
  layout 'mailer'
end
