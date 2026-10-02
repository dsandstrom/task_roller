# frozen_string_literal: true

class ProjectTasksSubscription < ApplicationRecord
  MESSAGE = 'already subscribed to project tasks'

  validates :user_id, uniqueness: { scope: :project_id, message: MESSAGE }

  belongs_to :user
  belongs_to :project
end
