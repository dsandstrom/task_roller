# frozen_string_literal: true

module Devise
  class MailerPreview < ActionMailer::Preview
    def confirmation_instructions
      Devise::Mailer.confirmation_instructions(User.reporters.first, {})
    end

    def unlock_instructions
      Devise::Mailer.unlock_instructions(User.reporters.first, "faketoken")
    end

    def reset_password_instructions
      Devise::Mailer
        .reset_password_instructions(User.reporters.first, "faketoken")
    end
  end
end
