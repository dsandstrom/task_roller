# frozen_string_literal: true

Fabricator(:project, alias: %i[visible_project external_project]) do
  name { sequence(:projects) { |n| "Project Name #{n + 1}" } }
  visible true
  internal false
  category
end

Fabricator(:invisible_project, from: :project) do
  name { sequence(:projects) { |n| "Archived Project Name #{n + 1}" } }
  visible false
end

Fabricator(:internal_project, from: :project) do
  name { sequence(:projects) { |n| "Internal Project Name #{n + 1}" } }
  internal true
end
