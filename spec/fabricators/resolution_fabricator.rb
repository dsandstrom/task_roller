Fabricator(:resolution) do
  approved nil

  before_create do |resolution|
    resolution.issue ||=
      if resolution.user
        Fabricate(:pending_issue, user: resolution.user)
      else
        Fabricate(:pending_issue)
      end
    resolution.user ||= resolution.issue.user
  end
end

Fabricator(:pending_resolution, from: :resolution)

Fabricator(:approved_resolution, from: :resolution) do
  approved true
end

Fabricator(:disapproved_resolution, from: :resolution) do
  approved false
end
