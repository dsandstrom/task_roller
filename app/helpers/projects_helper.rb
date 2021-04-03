# frozen_string_literal: true

module ProjectsHelper
  def project_tags(project)
    content_tag :p, class: 'project-tags' do
      concat project_invisible_tag(project)
      concat project_internal_tag(project)
    end
  end

  def project_breadcrumb_pages(project)
    category = project.category
    return unless category

    pages = category_breadcrumb_pages(category)
    pages << [category.name, category_path(category)]
    if category.visible? && !project.visible?
      pages << ['Archived Projects', archived_category_projects_path(category)]
    end
    pages
  end

  def project_header(project, options = {})
    category = project.category
    return unless category

    pages = [project_header_first_column(project),
             project_header_second_column(project, options)]

    content_for :header do
      concat content_tag(:div, safe_join(pages), class: 'columns')
      concat project_nav(project)
    end
  end

  def project_page?(project)
    pages = [project_path(project), project_tasks_path(project),
             project_issues_path(project)]
    pages.any? { |path| current_page?(path) }
  end

  def new_project(category)
    Project.new(category_id: category.id)
  end

  private

    def project_header_heading(project)
      if params[:controller] == 'projects' && params[:action] == 'show'
        return project.name
      end

      link_to(project.name, project_path(project))
    end

    def project_nav(project)
      content_tag :p, class: 'page-nav project-nav' do
        safe_join(navitize(project_nav_links(project)))
      end
    end

    def project_nav_links(project)
      [['Project', project], ['Issues', project_issues_path(project)],
       ['Tasks', project_tasks_path(project)], new_project_issue_link(project),
       new_project_task_link(project), edit_project_link(project)].compact
    end

    def new_project_issue_link(project)
      return unless can?(:create, new_issue(project))

      ['Report Issue', new_project_issue_path(project),
       { class: 'create-link' }]
    end

    def new_project_task_link(project)
      return unless can?(:create, new_task(project))

      ['Plan Task', new_project_task_path(project), { class: 'create-link' }]
    end

    def edit_project_link(project)
      return unless can?(:update, project)

      ['Settings', edit_project_path(project), { class: 'destroy-link' }]
    end

    def project_page_title(project)
      title =
        case params[:controller]
        when 'issues'
          issues_page_title(project.name)
        when 'tasks'
          tasks_page_title(project.name)
        else
          projects_page_title(project)
        end
      enable_page_title title
    end

    def projects_page_title(project)
      if params[:action] == 'edit'
        "Edit Project: #{project.name}"
      else
        "Project: #{project.name} (#{project.category&.name})"
      end
    end

    def project_header_first_column(project)
      content_tag :div, class: 'first-column' do
        concat breadcrumbs(project_breadcrumb_pages(project))
        concat content_tag(:h1, project_header_heading(project))
        concat project_tags(project)
        concat project_page_title(project)
      end
    end

    def project_header_second_column(project, options)
      return unless options[:subscriptions].present?

      buttons = options[:subscriptions].map do |s|
        content = render(s, project: project)
        return nil if content == "\n"

        content
      end.compact
      return unless buttons&.any?

      content_tag :div, class: 'second-column' do
        content_tag :div, safe_join(buttons)
      end
    end
end
