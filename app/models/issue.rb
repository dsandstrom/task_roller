# frozen_string_literal: true

# TODO: add CustomField/Value/Option for more issue/task attrs

class Issue < ApplicationRecord
  belongs_to :user # reporter
  belongs_to :issue_type
  belongs_to :project
  delegate :category, to: :project

  validates :summary, presence: true, length: { maximum: 200 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :user_id, presence: true
  validates :issue_type_id, presence: true
  validates :project_id, presence: true
end
