# frozen_string_literal: true

class IssueMailer < ApplicationMailer
  # TODO: show old status too
  def status_change
    @issue = params[:issue]
    @user = params[:user]
    options = { to: @user.email }
    options[:subject] = "Task Roller Update for Issue##{@issue.id}"

    mail(options)
  end
end
