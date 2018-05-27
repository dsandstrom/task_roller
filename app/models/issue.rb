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

  # INSTANCE

  def description_html
    @description_html ||= markdown.render(description)
  end

  private

    def markdown
      options = { no_intra_emphasis: true, tables: false, autolink: true,
                  strikethrough: true, space_after_headers: true,
                  superscript: false, underline: false, quote: false,
                  footnotes: false, fenced_code_blocks: true,
                  disable_indented_code_blocks: true }
      Redcarpet::Markdown.new(HTMLRenderer.new, options)
    end
end
