# frozen_string_literal: true

Fabricator(:review) do
  task { Fabricate(:open_task) }
  user { Fabricate(:user_reviewer) }
  approved nil
end

Fabricator(:pending_review, from: :review)

Fabricator(:approved_review, from: :review) do
  approved true
end

Fabricator(:disapproved_review, from: :review) do
  approved false
end
