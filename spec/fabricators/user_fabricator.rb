# frozen_string_literal: true

Fabricator(:user) do
  name { |n| "User Name #{n + 1}" }
  email { |n| "user-email-#{n + 1}@example.com" }
  employee
end
