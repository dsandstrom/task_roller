# frozen_string_literal: true

class RollerConnection < ApplicationRecord
  validates :source_id, presence: true
  validates :target_id, presence: true
end
