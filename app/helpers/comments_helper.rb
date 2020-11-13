# frozen_string_literal: true

module CommentsHelper
  def comment_button_text(comment)
    return 'Update Comment' if comment.persisted?

    'Add Comment'
  end

  def formatted_dates(object)
    created_date = format_date(object.created_at)
    return created_date if object.updated_at == object.created_at

    "#{created_date} (ed. #{format_date(object.updated_at)})"
  end
end
