# frozen_string_literal: true

# TODO: allow reporting comments to admin

class RollerComment < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :body, presence: true

  default_scope { order(created_at: :asc) }

  def body_html
    @body_html ||= (RollerMarkdown.new.render(body) || '')
  end
end
