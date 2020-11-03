# frozen_string_literal: true

module ProjectsHelper
  def project_tags(project)
    content_tag :p, class: 'project-tags' do
      concat project_visible_tag(project)
      concat project_internal_tag(project)
    end
  end

  def project_header(project)
    category = project.category
    return unless category

    content_tag :header, class: 'project-header' do
      concat breadcrumbs([['Categories', categories_path],
                          [category.name, category_path(category)]])
      concat content_tag(:h1, project_header_heading(project))
      concat project_tags(project)
      concat project_nav(project)
    end
  end

  private

    def project_breadcrumbs(project)
      category = project.category
      breadcrumbs(project_breadcrumb_pages(category, project))
    end

    # def project_breadcrumb_pages(category, project)
    #   related = [['Categories', categories_path],
    #              [category.name, category_path(category)]]
    #   if params[:controller] != 'projects'
    #     related += [[project.name, project_path(project)]]
    #   end
    #   if params[:controller] == 'issues'
    #     related +=
    #       [['Project Tasks', project_tasks_path(project)]]
    #   end
    #   return related unless params[:controller] == 'tasks'
    #
    #   related +
    #     [['Project Issues', project_issues_path(project)]]
    # end

    def project_tag(text, klass)
      content_tag :span, text, class: "tag tag-#{klass}"
    end

    def project_visible_tag(project)
      if project.visible?
        text = 'Visible'
        klass = 'visible'
      else
        text = 'Invisible'
        klass = 'invisible'
      end

      project_tag text, klass
    end

    def project_internal_tag(project)
      if project.internal?
        text = 'Internal'
        klass = 'internal'
      else
        text = 'External'
        klass = 'external'
      end

      project_tag text, klass
    end

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
               link_to_unless_current('Tasks', project_tasks_path(project))]
      links.append(new_project_issue_link(project)) if can?(:create, Issue)
      links.append(new_project_task_link(project)) if can?(:create, Task)
      return links unless can?(:update, project)

      links.append(edit_project_link(project))
    end

    def new_project_issue_link(project, options = {})
      return unless can?(:create, Issue)

      link_to_unless_current('Report Issue', new_project_issue_path(project),
                             class: options[:class])
    end

    def new_project_issue_button(project)
      new_project_issue_link(project, class: 'button button-success')
    end

    def new_project_task_link(project, options = {})
      return unless can?(:create, Task)

      link_to_unless_current('Plan Task', new_project_task_path(project),
                             class: options[:class])
    end

    def new_project_task_button(project)
      new_project_task_link(project, class: 'button button-success')
    end

    def edit_project_link(project)
      link_to_unless_current('Edit Project', edit_project_path(project),
                             class: 'warning-link')
    end
end
