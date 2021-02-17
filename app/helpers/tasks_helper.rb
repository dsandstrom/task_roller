# frozen_string_literal: true

module TasksHelper
  def task_header(task)
    project = task.project
    return unless project

    category = project.category
    return unless category

    items = [breadcrumbs(task_header_pages(task)), task_header_title(task),
             project_and_task_tags(task)].compact

    task_page_title(task)
    content_for :header do
      safe_join(items)
    end
  end

  def project_and_task_tags(task)
    project = task.project
    tags = [project_invisible_tag(project), project_internal_tag(project),
            task_type_tag(task.task_type), task_status_tag(task)].compact

    content_tag :div, class: 'project-tags task-tags' do
      safe_join(tags)
    end
  end

  def task_tags(task)
    tags = [task_type_tag(task.task_type), task_status_tag(task)]

    content_tag :div, class: 'task-tags' do
      safe_join(tags)
    end
  end

  def new_task(project)
    Task.new(project_id: project.id, user_id: current_user.id)
  end

  def new_task_connection(task)
    TaskConnection.new(source_id: task.id, user_id: current_user.id)
  end

  def new_task_closure(task)
    TaskClosure.new(task_id: task.id, user_id: current_user.id)
  end

  def new_task_reopening(task)
    TaskReopening.new(task_id: task.id, user_id: current_user.id)
  end

  def new_task_comment(task)
    TaskComment.new(task_id: task.id, user_id: current_user.id)
  end

  def new_task_assignee(task)
    TaskAssignee.new(task_id: task.id, assignee_id: current_user.id)
  end

  def new_progression(task)
    Progression.new(task_id: task.id, user_id: current_user.id)
  end

  def new_review(task)
    Review.new(task_id: task.id, user_id: current_user.id)
  end

  private

    def task_header_title(task)
      heading = task.heading
      unless params[:controller] == 'tasks' && params[:action] == 'show'
        heading = link_to(heading, task_path(task))
      end

      content_tag :div, class: 'task-title' do
        content_tag :h1, heading, class: 'task-heading'
      end
    end

    def task_header_pages(task)
      project = task.project
      category = task.category
      return unless category

      [[category.name, category_projects_path(category)],
       ['Category Tasks', category_tasks_path(category)],
       project_breadcrumb_item(project),
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
