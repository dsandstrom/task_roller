# frozen_string_literal: true

module IssuesHelper
  def issue_header(issue, project, category)
    pages = []
    pages << [category.name, category] if category
    pages << project_breadcrumb_item(project) if project

    content_tag :header, class: 'issue-header' do
      concat issue_title(issue)
      concat breadcrumbs(pages)
    end
  end

  private

    def issue_title(issue)
      content_tag :div, class: 'issue-title' do
        concat content_tag :h1, "Issue: #{issue.summary}",
                           class: 'issue-summary'
        concat issue_type_tag issue.issue_type
      end
    end
end
