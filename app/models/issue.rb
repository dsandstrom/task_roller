# frozen_string_literal: true

class Issue < ApplicationRecord
  belongs_to :user # reporter
  belongs_to :issue_type
  belongs_to :project

  validates :summary, presence: true, length: { maximum: 200 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :user_id, presence: true
  validates :issue_type_id, presence: true
  validates :project_id, presence: true
end
