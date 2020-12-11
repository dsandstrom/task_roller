# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@task-roller.net'
  layout 'mailer'
end
