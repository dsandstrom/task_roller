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
      concat content_tag(:h1, project_header_heading(project))
      concat breadcrumbs([[category.name, category_path(category)]])
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

    def project_header_heading(project)
      if params[:controller] == 'projects' && params[:action] == 'show'
        return project.name
      end

      link_to(project.name, category_project_path(project.category, project))
    end
end
