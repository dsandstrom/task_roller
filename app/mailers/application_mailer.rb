# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'Task Shipper <noreply@taskshipper.com>'
  layout 'mailer'
end
