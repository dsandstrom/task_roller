# frozen_string_literal: true

module TasksHelper
  def task_header(task)
    project = task.project
    return unless project

    category = project.category
    return unless category

    content_tag :header, class: 'task-header' do
      concat breadcrumbs(task_header_pages(task))
      concat task_header_title(task)
      concat task_page_title(task)
    end
  end

  def task_tags(task)
    tags = [task_type_tag(task.task_type), task_status_tag(task)]

    content_tag :div, class: 'task-tags' do
      safe_join(tags)
    end
  end

  private

    def task_header_title(task)
      heading = task.heading
      unless params[:controller] == 'tasks' && params[:action] == 'show'
        heading = link_to(heading, task_path(task))
      end

      content_tag :div, class: 'task-title' do
        concat content_tag :h1, heading, class: 'task-heading'
        concat task_type_tag task.task_type
        concat task_status_tag task
      end
    end

    def task_header_pages(task)
      project = task.project
      category = task.category
      return unless category

      [[category.name, category], project_breadcrumb_item(project),
       ['Project Tasks', project_tasks_path(project)]]
    end

    def task_page_title(task)
      title =
        if params[:controller] == 'task_comments'
          "Comment for #{task.heading}"
        elsif params[:action] == 'edit'
          "Edit #{task.heading}"
        else
          task.heading
        end
      enable_page_title title
    end

    def tasks_page_title(title)
      if params[:action] == 'new'
        "New Task for #{title}"
      else
        "Tasks for #{title}"
      end
    end

    def task_status_tag(task)
      value = task.status
      return unless value

      option = Task::STATUS_OPTIONS[value.parameterize.underscore.to_sym]
      return unless option

      color = option[:color]
      return unless color

      content_tag :span, value, class: "status-tag roller-type-color-#{color}"
    end
end
