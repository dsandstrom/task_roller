# frozen_string_literal: true

class CategoryTasksSubscription < ApplicationRecord
  MESSAGE = 'already subscribed to category tasks'

  validates :user_id, uniqueness: { scope: :category_id, message: MESSAGE }

  belongs_to :user
  belongs_to :category
end
