# frozen_string_literal: true

# TODO: add friendly_id/slug

class Project < ApplicationRecord
  belongs_to :category

  validates :name, presence: true, length: { maximum: 250 }
  validates :category_id, presence: true
  validates :category, presence: true, if: :category_id
end
