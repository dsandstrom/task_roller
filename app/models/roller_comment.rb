# frozen_string_literal: true

class RollerComment < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :body, presence: true

  default_scope { order(created_at: :asc) }
end