# frozen_string_literal: true

# TODO: add friendly_id/slug
# TODO: add icon options
# TODO: add image

class Project < ApplicationRecord
  belongs_to :category

  validates :name, presence: true, length: { maximum: 250 },
                   uniqueness: { scope: :category_id, case_sensitive: false }
  validates :category_id, presence: true
  validates :category, presence: true, if: :category_id
end
