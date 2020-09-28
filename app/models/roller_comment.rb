# frozen_string_literal: true

# TODO: allow reporting comments to admin
# TODO: color code comment css (op-blue, bob-pink, sally-yellow)
# makes it easier to recognize comments from same user

class RollerComment < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
  validates :user, presence: true, if: :user_id
  validates :body, presence: true

  default_scope { order(created_at: :asc) }

  def body_html
    @body_html ||= (RollerMarkdown.new.render(body) || '')
  end
end
