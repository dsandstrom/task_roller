# frozen_string_literal: true

class CategoryTasksSubscription < ApplicationRecord
  MESSAGE = 'already subscribed to category tasks'

  validates :category_id, presence: true
  validates :user_id, presence: true,
                      uniqueness: { scope: :category_id, message: MESSAGE }

  belongs_to :user
  belongs_to :category
end
