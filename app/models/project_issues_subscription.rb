# frozen_string_literal: true

class ProjectIssuesSubscription < ApplicationRecord
  MESSAGE = 'already subscribed to project issues'

  validates :user_id, uniqueness: { scope: :project_id, message: MESSAGE }

  belongs_to :user
  belongs_to :project
end
