# frozen_string_literal: true

module TasksHelper # rubocop:disable Metrics/ModuleLength
  def task_header(task)
    project = task.project
    return unless project

    category = project.category
    return unless category

    items = [breadcrumbs(task_header_pages(task)), task_header_title(task),
             project_and_task_tags(project, task)].compact

    task_page_title(task)
    content_for :header do
      safe_join(items)
    end
  end

  def project_and_task_tags(project, task)
    assign_dropdown = task_assign_dropdown(task)
    edit_dropdown = task_edit_dropdown(task)
    status_dropdown = task_status_dropdown(task)

    assign_button = task_assign_button(task, dropdown: assign_dropdown.present?)
    status_button = task_status_button(task, dropdown: status_dropdown.present?)
    type_button = task_type_button(task, dropdown: edit_dropdown.present?)
    tags = [project_invisible_tag(project), project_internal_tag(project),
            type_button, status_button, assign_button, assign_dropdown,
            edit_dropdown, status_dropdown].compact

    content_tag :span, safe_join(tags), class: 'project-tags task-tags'
  end

  def task_tags(task)
    tags = [task_type_button(task, dropdown: false),
            task_status_button(task, dropdown: false)]

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

      [[category.name, category_path(category)],
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

    def task_status_color(value)
      option = Task::STATUS_OPTIONS[value.parameterize.underscore.to_sym]
      return unless option

      option[:color]
    end

    def task_status_button(task, dropdown: false)
      value = task.status
      return unless value

      klass =
        "task-tag task-status-tag roller-type-color-#{task_status_color(value)}"
      parts = [content_tag(:span, value.titleize, class: 'status-value')]
      if dropdown
        parts << status_dropdown_link
        klass += ' status-button'
      end
      content_tag :span, safe_join(parts), class: klass
    end

    def task_type_button(task, dropdown: false)
      task_type = task.task_type
      return unless task_type

      klass = "task-type-tag #{roller_type_color(task_type)}"
      parts = [roller_type_icon(task_type),
               content_tag(:span, task_type.name, class: 'type-value')]
      if dropdown
        parts << task_type_dropdown_link
        klass += ' task-type-button'
      end
      content_tag :span, safe_join(parts), class: klass
    end

    def task_type_dropdown_link
      link_to '', 'javascript:void(0)',
              class: 'dropdown-link task-type-dropdown-link',
              title: 'Edit Task'
    end

    def task_status_dropdown(task)
      options = { class: 'dropdown-menu status-dropdown',
                  data: { link: 'status-dropdown-link' } }

      containers = [task_status_user_container(task),
                    task_status_reviewer_container(task)].compact
      return unless containers.any?

      content_tag :div, options do
        safe_join(containers)
      end
    end

    def task_status_reviewer_container(task)
      links = task_status_reviewer_links(task)
      return unless links&.any?

      klass = 'dropdown-menu-container status-reviewer-actions'
      content_tag :div, class: klass do
        concat content_tag :span, 'Review Actions', class: 'dropdown-menu-title'
        concat safe_join(navitize(links, class: 'button button-clear'))
      end
    end

    # TODO: add reviews
    def task_open_status_reviewer_links(task)
      return if task.in_review?

      links = []
      if can?(:create, new_task_connection(task))
        links << ['Mark as Duplicate', new_task_connection_path(task)]
      end
      if can?(:create, new_task_closure(task))
        links << ['Close Task', task_closures_path(task),
                  { method: :post }]
      end
      links
    end

    def task_connection_links(connection)
      return unless can?(:destroy, connection)

      confirm = 'Are you sure you want to remove the connection to '\
                "\"#{connection.target.short_summary}\" and reopen "\
                'this task?'

      [['Reopen Task', connection,
        { method: :delete, data: { confirm: confirm } }]]
    end

    def task_closed_status_reviewer_links(task)
      connection = task.source_connection
      if connection
        task_connection_links(connection)
      elsif can?(:create, new_task_reopening(task))
        [['Reopen Task', task_reopenings_path(task),
          { method: :post }]]
      end
    end

    def task_status_reviewer_links(task)
      if task.in_review?
        review = task.current_review
        return unless review

        task_review_links(task, review)
      elsif task.open?
        task_open_status_reviewer_links(task)
      else
        task_closed_status_reviewer_links(task)
      end
    end

    def task_status_user_container(task)
      links = task_status_user_links(task)
      return unless links&.any?

      content_tag :div, class: 'dropdown-menu-container status-user-actions' do
        concat content_tag :span, 'User Actions', class: 'dropdown-menu-title'
        concat safe_join(navitize(links, class: 'button button-clear'))
      end
    end

    def task_status_user_links(task)
      task_in_review_status_user_links(task) if task.in_review?
    end

    def task_review_links(task, review)
      links = []
      if can?(:approve, review)
        links << ['approve', approve_task_review_path(task, review),
                  { method: :patch, class: 'button-success' }]
      end
      if can?(:disapprove, review)
        links << ['disapprove', disapprove_task_review_path(task, review),
                  { method: :patch, class: 'button-warning' }]
      end
      links
    end

    def task_in_review_status_user_links(task)
      review = task.current_review
      return unless review

      links = []
      if can?(:destroy, review)
        confirm = 'Are you sure you want to cancel the review?'
        links << ['cancel review', task_review_path(task, review),
                  { method: :delete, data: { confirm: confirm },
                    class: 'button-warning' }]
      end
      links
    end

    def task_assign_links(task)
      links = task_new_review_links(task) || []
      task_assignee = task.task_assignees.find_by(assignee_id: current_user.id)
      if task_assignee
        task_assignee_and_progression_links(task, task_assignee)
          .each { |l| links << l }
      elsif can?(:create, new_task_assignee(task))
        links << ['Assign Myself', task_task_assignees_path(task),
                  { method: :post }]
      end

      links
    end

    def task_assignee_and_progression_links(task, task_assignee)
      progression =
        task.progressions.unfinished.find_by(user_id: current_user.id)
      if progression
        task_progression_links(task, progression)
      else
        task_assignee_links(task, task_assignee)
      end
    end

    def task_progression_links(task, progression)
      return unless can?(:finish, progression)

      [['pause task', finish_task_progression_path(task, progression),
        { method: :patch }]]
    end

    def task_new_progression_link(task)
      ['start task', task_progressions_path(task), { method: :post }]
    end

    def task_new_review_links(task)
      return unless can?(:create, new_review(task))

      [['Mark Complete', task_reviews_path(task),
        { method: :post, class: 'button-success' }]]
    end

    def task_unassign_link(task, task_assignee)
      confirm =
        "Are you sure you want to unassign yourself from #{task.heading}?"

      ['Unassign Myself', task_task_assignee_path(task, task_assignee),
       { method: :delete, data: { confirm: confirm }, class: 'button-warning' }]
    end

    def task_assignee_links(task, task_assignee)
      links = []
      if can?(:create, new_progression(task))
        links << task_new_progression_link(task)
      end
      if can?(:destroy, task_assignee)
        links << task_unassign_link(task, task_assignee)
      end
      links
    end

    def task_edit_dropdown(task)
      options = { class: 'dropdown-menu task-dropdown',
                  data: { link: 'task-type-dropdown-link' } }

      containers = [task_user_container(task),
                    task_reviewer_container(task)].compact
      return unless containers.any?

      content_tag :div, options do
        safe_join(containers)
      end
    end

    def task_reviewer_container(task)
      links = []
      if can?(:move, task) && !current_page?(move_task_path(task))
        links << ['Move to Different Project', move_task_path(task)]
      end
      return if links.none?

      content_tag :div, class: 'dropdown-menu-container task-user-actions' do
        concat content_tag :span, 'Review Actions', class: 'dropdown-menu-title'
        concat safe_join(navitize(links, class: 'button button-clear'))
      end
    end

    def task_user_container(task)
      links = []
      if can?(:update, task) && !current_page?(edit_task_path(task))
        links << ['Edit Task', edit_task_path(task)]
      end
      return if links.none?

      content_tag :div, class: 'dropdown-menu-container task-user-actions' do
        concat content_tag :span, 'User Actions', class: 'dropdown-menu-title'
        concat safe_join(navitize(links, class: 'button button-clear'))
      end
    end

    def task_assign_button_value(task)
      task_assignee = task.task_assignees.find_by(assignee_id: current_user.id)
      progression =
        task.progressions.unfinished.find_by(user_id: current_user.id)

      if progression
        ['In Progress to Me', 'yellow']
      elsif task_assignee
        ['Assigned to Me', 'green']
      else
        ['Not Assigned to Me', 'default']
      end
    end

    def task_assign_button(task, dropdown: false)
      value, color = task_assign_button_value(task)
      klass = "task-tag task-assign-tag roller-type-color-#{color}"
      parts = [content_tag(:span, value, class: 'assign-value')]
      if dropdown
        parts << task_assign_dropdown_link
        klass += ' task-button assign-button'
      end
      content_tag :span, safe_join(parts), class: klass
    end

    def task_assign_dropdown(task)
      options = { class: 'dropdown-menu assign-dropdown',
                  data: { link: 'task-assign-dropdown-link' } }

      links = task_assign_links(task) if task.open? && !task.in_review?
      return unless links&.any?

      content_tag :div, options do
        safe_join(navitize(links, class: 'button button-clear'))
      end
    end

    def task_assign_dropdown_link
      link_to '', 'javascript:void(0)',
              class: 'dropdown-link task-assign-dropdown-link',
              title: 'Assignment Options'
    end
end
