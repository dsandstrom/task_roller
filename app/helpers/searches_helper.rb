module SearchesHelper
  def search_header(heading = nil)
    title = 'Issue & Task Search'
    enable_page_title title
    content_for :header do
      concat content_tag(:h1, title)
      concat content_tag(:h2, heading) if heading.present?
    end
  end

  def search_result_turbo_frame(search_result)
    frame_tag =
      if search_result.issue?
        "turbo_issue_#{search_result.id}"
      else
        "turbo_task_#{search_result.id}"
      end

    turbo_frame_tag frame_tag do
      render search_result
    end
  end
end
