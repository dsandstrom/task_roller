# frozen_string_literal: true

class IssueMailer < ApplicationMailer
  attr_accessor :issue, :user, :old_status, :new_status

  def status_change
    set_instance_variables

    options = { to: @user.email }
    options[:subject] = "Task Roller Update for Issue##{@issue.id}"

    mail(options)
  end

  private

    def set_instance_variables
      %i[issue user old_status new_status].each do |attribute|
        send("#{attribute}=", params[attribute])
      end
    end
end
