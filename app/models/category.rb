# frozen_string_literal: true

# TODO: add dependent destroy
# TODO: add category_reviewers
# TODO: add icon options
# TODO: add image

class Category < ApplicationRecord
  has_many :projects

  validates :name, presence: true, length: { maximum: 200 }
end
