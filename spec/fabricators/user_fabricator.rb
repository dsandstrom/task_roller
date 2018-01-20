# frozen_string_literal: true

Fabricator(:user, aliases: :user_worker) do
  name { sequence(:users) { |n| "User Name #{n + 1}" } }
  email { sequence(:users) { |n| "user-email-#{n + 1}@example.com" } }
  employee { Fabricate(:worker) }
end

Fabricator(:user_reporter, from: :user) do
  name { sequence(:users) { |n| "Reporter Name #{n + 1}" } }
  email { sequence(:users) { |n| "reporter-email-#{n + 1}@example.com" } }
  employee { Fabricate(:reporter) }
end

Fabricator(:user_reviewer, from: :user) do
  name { sequence(:users) { |n| "Reviewer Name #{n + 1}" } }
  email { sequence(:users) { |n| "reviewer-email-#{n + 1}@example.com" } }
  employee { Fabricate(:reviewer) }
end
