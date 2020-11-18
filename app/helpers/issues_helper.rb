# frozen_string_literal: true

module IssuesHelper
  def issue_header(issue)
    project = issue.project
    return unless project

    category = project.category
    return unless category

    items = [issue_header_breadcrumbs(category, project), issue_title(issue),
             issue_tags(issue), issue_page_title(issue)]
    content_tag :header, class: 'issue-header' do
      safe_join(items)
    end
  end

  def issue_tags(issue)
    tags = [issue_type_tag(issue.issue_type), issue_status_tag(issue)]

    content_tag :div, class: 'issue-tags' do
      safe_join(tags)
    end
  end

  def issue_status_tags(issue)
    content_tag :div, class: 'issue-tags' do
      issue_status_tag(issue)
    end
  end

  def new_issue(project)
    Issue.new(project_id: project.id, user_id: current_user.id)
  end

  # using build causes unpersisted entries to show up in render calls
  def new_resolution(issue)
    Resolution.new(issue_id: issue.id, user_id: current_user.id)
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

    def issue_status_tag(issue)
      value = issue.status
      return unless value

      option = Issue::STATUS_OPTIONS[value.parameterize.underscore.to_sym]
      return unless option

      color = option[:color]
      return unless color

      content_tag :span, value, class: "status-tag roller-type-color-#{color}"
    end
end
