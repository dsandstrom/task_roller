# frozen_string_literal: true

Fabricator(:resolution) do
  user { Fabricate(:user_worker) }
  approved nil

  before_validation do |resolution|
    return if resolution.issue

    resolution.issue =
      if resolution.user
        Fabricate(:closed_issue, user: resolution.user)
      else
        Fabricate(:closed_issue)
      end
  end
end

Fabricator(:pending_resolution, from: :resolution) do
end

Fabricator(:approved_resolution, from: :resolution) do
  approved true
end

Fabricator(:disapproved_resolution, from: :resolution) do
  approved false
end
