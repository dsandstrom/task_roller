# frozen_string_literal: true

# TODO: add CustomField/Value/Option for more issue/task attrs
# TODO: add visible boolean (for moderation)

class Issue < ApplicationRecord
  belongs_to :user # reporter
  belongs_to :issue_type
  belongs_to :project
  has_many :tasks, dependent: :nullify
  has_many :comments, class_name: 'IssueComment', foreign_key: :roller_id,
                      dependent: :destroy, inverse_of: :issue
  delegate :category, to: :project

  validates :summary, presence: true, length: { maximum: 200 }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :user_id, presence: true
  validates :issue_type_id, presence: true
  validates :project_id, presence: true

  # CLASS

  def self.all_open
    where(closed: false)
  end

  def self.all_closed
    where(closed: true)
  end

  def self.filter(filters = {})
    parent = filters[:project] || filters[:category]
    return Issue.none unless parent

    issues = parent.issues
    return Issue.none unless issues&.any?

    issues = issues.filter_by_status(filters[:status])
    issues.order(updated_at: :desc)
  end

  # used by .filter
  def self.filter_by_status(status)
    if status == 'open'
      all_open
    elsif status == 'closed'
      all_closed
    else
      all
    end
  end

  # INSTANCE

  def description_html
    @description_html ||= (RollerMarkdown.new.render(description) || '')
  end

  def short_summary
    @short_summary ||= summary&.truncate(100)
  end

  def open?
    !closed?
  end
end
