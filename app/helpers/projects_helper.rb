# frozen_string_literal: true

module ProjectsHelper
  def project_tags(project)
    content_tag :p, class: 'project-tags' do
      concat visible_tag(project)
      concat internal_tag(project)
    end
  end

  def project_header(project)
    category = project.category
    return unless category

    content_tag :header, class: 'project-header' do
      concat breadcrumbs([['Categories', categories_path],
                          [category.name, category_projects_path(category)]])
      concat content_tag(:h1, project_header_heading(project))
      concat project_tags(project)
      concat project_nav(project)
      concat project_page_title(project)
    end
  end

  def project_page?(project)
    pages = [project_path(project), project_tasks_path(project),
             project_issues_path(project)]
    pages.any? { |path| current_page?(path) }
  end

  private

    def project_header_heading(project)
      if params[:controller] == 'projects' && params[:action] == 'show'
        return project.name
      end

      link_to(project.name, project_path(project))
    end

    def project_nav(project)
      content_tag :p, class: 'project-nav' do
        safe_join(project_nav_links(project), divider_with_spaces)
      end
    end

    def project_nav_links(project)
      links = [link_to_unless_current('Project', project),
               link_to_unless_current('Issues', project_issues_path(project)),
               link_to_unless_current('Tasks', project_tasks_path(project)),
               new_project_issue_link(project),
               new_project_task_link(project)].compact
      return links unless can?(:update, project)

      links.append(edit_project_link(project))
    end

    def new_project_issue_link(project, options = {})
      return unless can?(:create, new_issue(project))

      link_to_unless_current('Report Issue', new_project_issue_path(project),
                             class: options[:class])
    end

    def new_project_task_link(project, options = {})
      return unless can?(:create, new_task(project))

      link_to_unless_current('Plan Task', new_project_task_path(project),
                             class: options[:class])
    end

    def edit_project_link(project)
      link_to_unless_current('Settings', edit_project_path(project),
                             class: 'destroy-link')
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
end
