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
      concat issue_page_title(issue)
    end
  end

  def issue_status_tags(issue)
    value = issue.status
    tags =
      if issue.closed?
        issue_closed_status_tags(value)
      else
        issue_open_status_tags(value)
      end

    content_tag :p, class: 'issue-status-tags' do
      safe_join(tags, ' ')
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

    def issue_page_title(issue)
      title =
        if params[:controller] == 'issue_comments'
          "Comment for #{issue.heading}"
        elsif params[:action] == 'edit'
          "Edit #{issue.heading}"
        else
          issue.heading
        end
      enable_page_title title
    end

    def issues_page_title(title)
      if params[:action] == 'new'
        "New Issue for #{title}"
      else
        "Issues from #{title}"
      end
    end

    def issue_closed_status_tags(value)
      tags = [issue_closed_status_tag]
      return tags if value == 'closed'

      tags.append(issue_closed_status_modifier_tag(value))
    end

    def issue_open_status_tags(value)
      tags = [issue_open_status_tag]
      return tags if value == 'open'

      tags.append(issue_open_status_modifier_tag(value))
    end

    def issue_open_status_tag
      content_tag :span, 'open',
                  class: 'issue-status-tag roller-type-color-green'
    end

    def issue_closed_status_tag
      content_tag :span, 'closed',
                  class: 'issue-status-tag roller-type-color-red'
    end

    def issue_open_status_modifier_tag(modifier)
      content_tag :span, modifier,
                  class: 'issue-status-tag roller-type-color-yellow'
    end

    def issue_closed_status_modifier_tag(modifier)
      content_tag :span, modifier,
                  class: 'issue-status-tag roller-type-color-blue'
    end
end
