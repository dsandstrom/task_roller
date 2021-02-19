# frozen_string_literal: true

# TODO: preload project, category, user

class SearchResult < ApplicationRecord
  belongs_to :user
  belongs_to :project
  delegate :category, to: :project
  # TODO: if issue
  belongs_to :task_type
  # TODO: if task
  belongs_to :issue
  belongs_to :issue_type
  has_many :task_assignees, primary_key: :id, foreign_key: :task_id
  has_many :assignees, through: :task_assignees
end
