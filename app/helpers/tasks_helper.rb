# frozen_string_literal: true

module TasksHelper
  def task_header(task)
    project = task.project
    return unless project

    category = project.category
    return unless category

    pages = []
    pages << [category.name, category] if category
    pages << project_breadcrumb_item(project) if project
    pages << issue_breadcrumb_item(category, project, task.issue) if task.issue

    content_tag :header, class: 'task-header' do
      concat task_title(category, project, task)
      concat breadcrumbs(pages)
    end
  end

  private

    def task_title(category, project, task)
      heading = task.heading
      unless params[:controller] == 'tasks' && params[:action] == 'show'
        heading =
          link_to(heading, category_project_task_path(category, project, task))
      end

      content_tag :div, class: 'task-title' do
        concat content_tag :h1, heading, class: 'task-heading'
        concat task_type_tag task.task_type
      end
    end
end
