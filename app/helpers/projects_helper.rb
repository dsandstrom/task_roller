# frozen_string_literal: true

module ProjectsHelper
  def project_tags(project)
    content_tag :p, class: 'project-tags' do
      concat project_visible_tag(project)
      concat project_internal_tag(project)
    end
  end

  def project_header(project, options = {})
    category = project.category
    return unless category

    content_tag :header, class: 'project-header' do
      concat content_tag(:h1, project_header_heading(project, options))
      concat breadcrumbs(project_header_pages(project, options))
      concat project_tags(project)
    end
  end

  private

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

    def project_header_heading(project, options = {})
      task = options[:task]
      category = project.category

      if task
        path = category_project_task_path(category, project, task)
        return link_to(task.heading, path)
      end

      path = category_project_path(category, project)
      link_to(project.name, path)
    end

    def project_header_pages(project, options)
      task = options[:task]
      category = project.category

      pages = [[category.name, category_path(category)]]
      return pages unless task

      pages << [project.name, category_project_path(category, project)]
    end
end
