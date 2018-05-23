# frozen_string_literal: true

Fabricator(:task_comment) do
  task
  user
  body 'Task Comment Body'
end
