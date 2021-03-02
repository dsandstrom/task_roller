# frozen_string_literal: true

module IssuesHelper # rubocop:disable Metrics/ModuleLength
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

    edit_dropdown = issue_edit_dropdown(issue)
    status_dropdown = issue_status_dropdown(issue)

    type_button =
      issue_type_button(issue, with_dropdown: edit_dropdown.present?)
    status_button =
      issue_status_button(issue, with_dropdown: status_dropdown.present?)

    tags = [project_invisible_tag(project), project_internal_tag(project),
            type_button, status_button, edit_dropdown, status_dropdown].compact
    content_tag :span, safe_join(tags), class: 'project-tags issue-tags'
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

      content_tag :span, class: "status-tag roller-type-color-#{color}" do
        content_tag :span, value.titleize, class: 'status-value'
      end
    end

    def issue_status_color(value)
      option = Issue::STATUS_OPTIONS[value.parameterize.underscore.to_sym]
      return unless option

      option[:color]
    end

    def issue_status_button(issue, with_dropdown: false)
      value = issue.status
      return unless value

      klass = "status-tag roller-type-color-#{issue_status_color(value)}"
      parts = [content_tag(:span, value.titleize, class: 'status-value')]
      if with_dropdown
        parts << status_dropdown_link
        klass += ' status-button'
      end
      content_tag :span, safe_join(parts), class: klass
    end

    def issue_type_button(issue, with_dropdown: false)
      issue_type = issue.issue_type
      return unless issue_type

      klass = "issue-type-tag #{roller_type_color(issue_type)}"
      parts = [roller_type_icon(issue_type),
               content_tag(:span, issue_type.name, class: 'type-value')]
      if with_dropdown
        parts << issue_type_dropdown_link
        klass += ' issue-type-button'
      end
      content_tag :span, safe_join(parts), class: klass
    end

    def status_dropdown_link
      link_to '', 'javascript:void(0)',
              class: 'dropdown-link status-dropdown-link',
              title: 'Change Status'
    end

    def issue_type_dropdown_link
      link_to '', 'javascript:void(0)',
              class: 'dropdown-link issue-type-dropdown-link',
              title: 'Edit Issue'
    end

    def issue_status_dropdown(issue)
      options = { class: 'dropdown-menu status-dropdown',
                  data: { link: 'status-dropdown-link' } }

      containers = [issue_status_user_container(issue),
                    issue_status_reviewer_container(issue)].compact
      return unless containers.any?

      content_tag :div, options do
        safe_join(containers)
      end
    end

    def issue_edit_dropdown(issue)
      options = { class: 'dropdown-menu issue-dropdown',
                  data: { link: 'issue-type-dropdown-link' } }

      containers = [issue_user_container(issue),
                    issue_reviewer_container(issue)].compact
      return unless containers.any?

      content_tag :div, options do
        safe_join(containers)
      end
    end

    def issue_open_status_reviewer_links(issue)
      links = []
      if can?(:create, new_issue_connection(issue))
        links << ['Mark as Duplicate', new_issue_connection_path(issue)]
      end
      if can?(:create, new_issue_closure(issue))
        links << ['Close Issue', issue_closures_path(issue),
                  { method: :post }]
      end
      links
    end

    def issue_connection_links(connection)
      return unless can?(:destroy, connection)

      confirm = 'Are you sure you want to remove the connection to '\
                "\"#{connection.target.short_summary}\" and reopen "\
                'this issue?'

      [['Reopen Issue', connection,
        { method: :delete, data: { confirm: confirm } }]]
    end

    def issue_closed_status_reviewer_links(issue)
      connection = issue.source_connection
      if connection
        issue_connection_links(connection)
      elsif can?(:create, new_issue_reopening(issue))
        [['Reopen Issue', issue_reopenings_path(issue),
          { method: :post }]]
      end
    end

    def issue_status_reviewer_links(issue)
      if issue.open?
        issue_open_status_reviewer_links(issue)
      else
        issue_closed_status_reviewer_links(issue)
      end
    end

    def issue_status_reviewer_container(issue)
      links = issue_status_reviewer_links(issue)
      return unless links&.any?

      klass = 'dropdown-menu-container status-reviewer-actions'
      content_tag :div, class: klass do
        concat content_tag :span, 'Review Actions', class: 'dropdown-menu-title'
        concat safe_join(navitize(links, class: 'button button-clear'))
      end
    end

    def issue_status_user_links(issue)
      return unless can?(:create, new_resolution(issue))

      options = %w[addressed open being_worked_on]
      return unless options.any? { |status| issue.status == status }

      if issue.status == 'addressed'
        [['Report Issue not Fixed', disapprove_issue_resolutions_path(issue),
          { method: :post }]]
      else
        [['Mark Resolved', approve_issue_resolutions_path(issue),
          { method: :post }]]
      end
    end

    def issue_status_user_container(issue)
      links = issue_status_user_links(issue)
      return unless links

      content_tag :div, class: 'dropdown-menu-container status-user-actions' do
        concat content_tag :span, 'User Actions', class: 'dropdown-menu-title'
        concat safe_join(navitize(links, class: 'button button-clear'))
      end
    end

    def issue_reviewer_container(issue)
      links = []
      if can?(:move, issue) && !current_page?(move_issue_path(issue))
        links << ['Move to Different Project', move_issue_path(issue)]
      end
      return if links.none?

      content_tag :div, class: 'dropdown-menu-container issue-user-actions' do
        concat content_tag :span, 'Review Actions', class: 'dropdown-menu-title'
        concat safe_join(navitize(links, class: 'button button-clear'))
      end
    end

    def issue_user_container(issue)
      links = []
      if can?(:update, issue) && !current_page?(edit_issue_path(issue))
        links << ['Edit Issue', edit_issue_path(issue)]
      end
      return if links.none?

      content_tag :div, class: 'dropdown-menu-container issue-user-actions' do
        concat content_tag :span, 'User Actions', class: 'dropdown-menu-title'
        concat safe_join(navitize(links, class: 'button button-clear'))
      end
    end
end
