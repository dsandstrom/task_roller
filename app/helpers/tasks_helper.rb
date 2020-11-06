# frozen_string_literal: true

module TasksHelper
  def task_header(task)
    project = task.project
    return unless project

    category = project.category
    return unless category

    content_tag :header, class: 'task-header' do
      concat breadcrumbs(task_header_pages(category, project, task))
      concat task_header_title(task)
      concat task_page_title(task)
    end
  end

  def task_tags(task)
    value = task.status
    tags =
      if task.closed?
        [task_type_tag(task.task_type), closed_status_tags(value)]
      else
        [task_type_tag(task.task_type), open_status_tags(value)]
      end

    content_tag :p, class: 'task-tags' do
      safe_join(tags, ' ')
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
      end
    end

    def task_header_pages(category, project, task)
      pages =
        [[category.name, category], project_breadcrumb_item(project),
         ['Project Tasks', project_tasks_path(project)]]
      return pages unless task.issue

      pages << issue_breadcrumb_item(task.issue)
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

    def closed_status_tags(value)
      tags = [closed_status_tag]
      return tags if value == 'closed'

      tags.append(closed_status_modifier_tag(value))
    end

    def open_status_tags(value)
      tags = [open_status_tag]
      return tags if value == 'open'

      tags.append(open_status_modifier_tag(value))
    end

    def open_status_tag
      content_tag :span, 'open',
                  class: 'status-tag roller-type-color-green'
    end

    def closed_status_tag
      content_tag :span, 'closed',
                  class: 'status-tag roller-type-color-red'
    end

    def open_status_modifier_tag(modifier)
      content_tag :span, modifier,
                  class: 'status-tag roller-type-color-yellow'
    end

    def closed_status_modifier_tag(modifier)
      content_tag :span, modifier,
                  class: 'status-tag roller-type-color-blue'
    end
end
