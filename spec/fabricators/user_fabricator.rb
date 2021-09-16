# frozen_string_literal: true

Fabricator(:user, aliases: :user_worker) do
  name { sequence(:users) { |n| "User Name #{n + 1}" } }
  email { sequence(:users) { |n| "user-email-#{n + 1}@example.com" } }
  employee_type { 'Worker' }
  password { '12345679' }
  password_confirmation { '12345679' }
  confirmed_at { Time.zone.now }
end

Fabricator(:user_admin, from: :user) do
  name { sequence(:users) { |n| "Admin Name #{n + 1}" } }
  email { sequence(:users) { |n| "admin-email-#{n + 1}@example.com" } }
  employee_type { 'Admin' }
end

Fabricator(:user_reporter, from: :user) do
  name { sequence(:users) { |n| "Reporter Name #{n + 1}" } }
  email { sequence(:users) { |n| "reporter-email-#{n + 1}@example.com" } }
  employee_type { 'Reporter' }
end

Fabricator(:user_reviewer, from: :user) do
  name { sequence(:users) { |n| "Reviewer Name #{n + 1}" } }
  email { sequence(:users) { |n| "reviewer-email-#{n + 1}@example.com" } }
  employee_type { 'Reviewer' }
end

Fabricator(:user_unemployed, from: :user) do
  name { sequence(:users) { |n| "Former User Name #{n + 1}" } }
  email { sequence(:users) { |n| "former-user-email-#{n + 1}@example.com" } }

  after_create do |user, _|
    user.update_attribute :employee_type, nil
  end
end
