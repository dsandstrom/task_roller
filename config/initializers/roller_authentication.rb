# frozen_string_literal: true

RollerAuthentication.setup do |config|
  config.users = User.joins(:employee)
end
