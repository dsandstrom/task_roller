# frozen_string_literal: true

class RollerType < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 },
                   uniqueness: { scope: :type }
  # TODO: add options for icon and color
  # TODO: validate icon, color are one of the options
  validates :icon, presence: true
  validates :color, presence: true
  validates :type, presence: true
end
