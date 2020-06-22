# frozen_string_literal: true

module TasksHelper
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

  private

    def task_title(task)
      content_tag :div, class: 'task-title' do
        concat content_tag :h1, task.heading, class: 'task-summary'
        concat task_type_tag task.task_type
      end
    end
end
