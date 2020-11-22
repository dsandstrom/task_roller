# frozen_string_literal: true

Fabricator(:category, alias: %i[visible_category external_category]) do
  name { sequence(:categories) { |n| "Category Name #{n + 1}" } }
  visible true
  internal false
end

Fabricator(:invisible_category, from: :category) do
  name { sequence(:categories) { |n| "Invisible Category Name #{n + 1}" } }
  visible false
end

Fabricator(:internal_category, from: :category) do
  name { sequence(:categories) { |n| "Internal Category Name #{n + 1}" } }
  internal true
end
