# frozen_string_literal: true

module TasksHelper
  def task_header(task)
    project = task.project
    return unless project

    category = project.category
    return unless category

    content_tag :header, class: 'task-header' do
      concat task_header_title(category, project, task)
      concat breadcrumbs(task_header_pages(category, project, task))
    end
  end

  private

    def task_header_title(category, project, task)
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

    def task_header_pages(category, project, task)
      pages = [[category.name, category], project_breadcrumb_item(project)]
      return pages unless task.issue

      pages << issue_breadcrumb_item(category, project, task.issue)
    end
end
