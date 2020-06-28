# frozen_string_literal: true

Fabricator(:progression) do
  task
  user
  finished false
end

Fabricator(:unfinished_progression, from: :progression) do
end

Fabricator(:finished_progression, from: :progression) do
  finished true
  finished_at { Time.now }
end
