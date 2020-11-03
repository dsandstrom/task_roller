# frozen_string_literal: true

class CategoryIssuesSubscription < ApplicationRecord
  MESSAGE = 'already subscribed to category issues'

  validates :category_id, presence: true
  validates :user_id, presence: true,
                      uniqueness: { scope: :category_id, message: MESSAGE }

  belongs_to :user
  belongs_to :category
end
