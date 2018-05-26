# frozen_string_literal: true

module ProjectsHelper
  def project_tags(project)
    content_tag :p, class: 'project-tags' do
      concat project_visible_tag(project)
      concat project_internal_tag(project)
    end
  end

  def project_header(project, category)
    content_tag :header, class: 'project-header' do
      concat content_tag(:h1, link_to(project.name,
                                      category_project_path(category, project)))
      concat content_tag(:p, link_to(category.name, category))
      concat project_tags(project)
    end
  end

  # TODO: move
  def breadcrumbs(views)
    return if views.none?

    content_tag :div, class: 'breadcrumbs' do
      views.each do |text, url, options|
        concat breadcrumb(text, url, options)
      end
    end
  end

  # TODO: move
  def task_header(task, project, category)
    pages = []
    pages << [category.name, category] if category
    pages << project_breadcrumb_item(project) if project
    pages << issue_breadcrumb_item(category, project, task.issue) if task.issue

    content_tag :header, class: 'issue-header' do
      concat task_title(task)
      concat breadcrumbs(pages)
    end
  end

  # TODO: move
  def issue_header(issue, project, category)
    pages = []
    pages << [category.name, category] if category
    pages << project_breadcrumb_item(project) if project

    content_tag :header, class: 'issue-header' do
      concat issue_title(issue)
      concat breadcrumbs(pages)
    end
  end

  private

    def project_breadcrumb_item(project)
      [project.name, category_project_path(project.category, project)]
    end

    def issue_breadcrumb_item(category, project, issue)
      [issue.summary,
       category_project_issue_path(category, project, issue),
       id: "task-issue-#{issue.id}"]
    end

    def breadcrumb(text, url, options = {})
      content_tag :span, class: 'breadcrumb' do
        link_to text, url, options
      end
    end

    def task_title(task)
      content_tag :div, class: 'task-title' do
        concat content_tag :h1, "Task: #{task.summary}", class: 'task-summary'
        concat task_type_tag task.task_type
      end
    end

    def issue_title(issue)
      content_tag :div, class: 'issue-title' do
        concat content_tag :h1, "Issue: #{issue.summary}",
                           class: 'issue-summary'
        concat issue_type_tag issue.issue_type
      end
    end

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
end
