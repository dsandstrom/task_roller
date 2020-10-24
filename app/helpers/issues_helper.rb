# frozen_string_literal: true

module IssuesHelper
  def issue_header(issue)
    project = issue.project
    return unless project

    category = project.category
    return unless category

    content_tag :header, class: 'issue-header' do
      concat issue_header_breadcrumbs(category, project)
      concat issue_title(issue)
    end
  end

  private

    def issue_title_heading(issue)
      heading = issue.heading
      if params[:controller] == 'issues' && params[:action] == 'show'
        return heading
      end

      link_to(heading, issue_path(issue))
    end

    def issue_title(issue)
      content_tag :div, class: 'issue-title' do
        concat content_tag :h1, issue_title_heading(issue),
                           class: 'issue-heading'
        concat issue_type_tag issue.issue_type
      end
    end

    def issue_header_breadcrumbs(category, project)
      pages = []
      pages << [category.name, category]
      pages << project_breadcrumb_item(project)
      pages << ['Project Issues', project_issues_path(project)]

      breadcrumbs(pages)
    end
end
