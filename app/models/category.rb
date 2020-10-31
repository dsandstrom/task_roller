# frozen_string_literal: true

# TODO: add CategorySubscription
# TODO: add friendly_id/slug
# TODO: add icon options
# TODO: add image

class Category < ApplicationRecord
  has_many :projects, dependent: :destroy
  has_many :issues, through: :projects
  has_many :tasks, through: :projects

  validates :name, presence: true, length: { maximum: 200 }
end
