# frozen_string_literal: true

class IssueMailer < ApplicationMailer
  def status_change
    @issue = params[:issue]
    @user = params[:user]
    @old_status = params[:old_status]
    @new_status = params[:new_status]

    options = { to: @user.email }
    options[:subject] = "Task Roller Update for Issue##{@issue.id}"

    mail(options)
  end
end
