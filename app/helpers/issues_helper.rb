# frozen_string_literal: true

module IssuesHelper
  def issue_header(issue)
    project = issue.project
    return unless project

    category = project.category
    return unless category

    items = [issue_header_breadcrumbs(category, project), issue_title(issue),
             project_and_issue_tags(issue)].compact

    issue_page_title(issue)
    content_for :header do
      safe_join(items)
    end
  end

  def project_and_issue_tags(issue)
    project = issue.project
    tags = [project_invisible_tag(project), project_internal_tag(project),
            issue_type_tag(issue.issue_type),
            issue_status_button(issue), issue_status_dropdown(issue)].compact

    content_tag :div, class: 'project-tags issue-tags' do
      safe_join(tags)
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

  def new_issue_closure(issue)
    IssueClosure.new(issue_id: issue.id, user_id: current_user.id)
  end

  def new_issue_reopening(issue)
    IssueReopening.new(issue_id: issue.id, user_id: current_user.id)
  end

  def new_issue_comment(issue)
    IssueComment.new(issue_id: issue.id, user_id: current_user.id)
  end

  def new_issue_connection(issue)
    IssueConnection.new(source_id: issue.id, user_id: current_user.id)
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
        content_tag :h1, issue_title_heading(issue), class: 'issue-heading'
      end
    end

    def issue_header_breadcrumbs(category, project)
      pages = []
      pages << [category.name, category_projects_path(category)]
      pages << ['Category Issues', category_issues_path(category)]
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

      content_tag :span, value.titleize,
                  class: "status-tag roller-type-color-#{color}"
    end

    def issue_status_button(issue)
      value = issue.status
      return unless value

      option = Issue::STATUS_OPTIONS[value.parameterize.underscore.to_sym]
      return unless option

      color = option[:color]
      return unless color

      klass = "status-tag roller-type-color-#{color}"
      parts = [content_tag(:span, value.titleize, class: 'status-value')]
      dropdown = issue_status_dropdown(issue)
      if dropdown
        parts << issue_status_dropdown_link
        klass += ' status-button'
      end
      content_tag :span, class: klass do
        safe_join(parts)
      end
    end

    def issue_status_dropdown_link
      link_to '', 'javascript:void(0)',
              class: 'dropdown-link status-dropdown-link',
              title: 'Change Status'
    end

    def issue_status_dropdown(issue)
      options = { class: 'dropdown-menu status-dropdown',
                  data: { link: 'status-dropdown-link' } }

      containers = [issue_status_user_actions(issue),
                    issue_status_reviewer_actions(issue)].compact
      return unless containers.any?

      content_tag :div, options do
        safe_join(containers)
      end
    end

    def issue_status_reviewer_actions(issue)
      links = []
      if issue.open?
        if can?(:create, new_issue_connection(issue))
          links << link_to('Mark as Duplicate',
                           new_issue_connection_path(issue),
                           class: 'button button-clear')
        end
        if can?(:create, new_issue_closure(issue))
          links << link_to('Close Issue', issue_closures_path(issue),
                           method: :post, class: 'button button-clear')
        end
      end
      if issue.closed?
        if issue.source_connection
          # TODO: add destroy connection link
        elsif can?(:create, new_issue_reopening(issue))
          links << link_to('Reopen Issue', issue_reopenings_path(issue),
                           method: :post, class: 'button button-clear')
        end
      end
      return if links.none?

      klass = 'dropdown-menu-container status-reviewer-actions'
      content_tag :div, class: klass do
        concat content_tag :span, 'Review Actions', class: 'dropdown-menu-title'
        concat safe_join(links)
      end
    end

    def issue_status_user_actions(issue)
      links = []
      if issue.status == 'addressed' && can?(:create, new_resolution(issue))
        links << link_to('Report Issue not Fixed',
                         disapprove_issue_resolutions_path(issue),
                         method: :post, class: 'button button-clear')
      elsif issue.status == 'open' || issue.status == 'being_worked_on'
        if can?(:create, new_resolution(issue))
          links << link_to('Mark Resolved',
                           approve_issue_resolutions_path(issue),
                           method: :post, class: 'button button-clear')
        end
      end
      return if links.none?

      content_tag :div, class: 'dropdown-menu-container status-user-actions' do
        concat content_tag :span, 'User Actions', class: 'dropdown-menu-title'
        concat safe_join(links)
      end
    end
end
