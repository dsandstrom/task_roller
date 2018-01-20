# frozen_string_literal: true

Fabricator(:user) do
  name { sequence(:users) { |n| "User Name #{n + 1}" } }
  email { sequence(:users) { |n| "user-email-#{n + 1}@example.com" } }
  employee
end
