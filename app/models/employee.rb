# frozen_string_literal: true

class Employee < ApplicationRecord
  has_one :user, dependent: :nullify
end
