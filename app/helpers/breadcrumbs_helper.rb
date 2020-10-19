# frozen_string_literal: true

module BreadcrumbsHelper
  def breadcrumbs(views = [])
    content_tag :div, class: 'breadcrumbs' do
      views.each do |text, url, options|
        concat breadcrumb(text, url, options)
      end
    end
  end

  private

    def project_breadcrumb_item(project)
      [project.name, category_project_path(project.category, project)]
    end

    def issue_breadcrumb_item(category, project, issue)
      [issue.heading,
       category_project_issue_path(category, project, issue),
       { id: "task-issue-#{issue.id}" }]
    end

    def breadcrumb(text, url, options = {})
      content_tag :span, class: 'breadcrumb' do
        link_to text, url, options
      end
    end
end
