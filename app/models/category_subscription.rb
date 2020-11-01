# frozen_string_literal: true

class CategorySubscription < ApplicationRecord
  validates :user_id, presence: true
  validates :category_id, presence: true
  validates :type, presence: true

  belongs_to :user
  belongs_to :category
end
