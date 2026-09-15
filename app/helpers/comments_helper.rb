module CommentsHelper
  def comment_button_text(comment)
    return 'Update Comment' if comment.persisted?

    'Add Comment'
  end

  def formatted_dates(object)
    created_date = format_date(object.created_at)
    return created_date if object.updated_at == object.created_at

    "#{created_date} (ed. #{format_date(object.updated_at)})"
  end

  def comment_footer(object, comment)
    return unless display_comment_footer?(comment)

    content_tag :footer, class: comment_footer_class(comment) do
      if object.is_a?(Task)
        task_comment_footer(object, comment)
      else
        issue_comment_footer(object, comment)
      end
    end
  end

  private

    def issue_comment_footer(object, comment)
      edit_links = issue_comment_edit_links(object, comment)
      create_links = issue_comment_create_links(object, comment)

      tags = []
      tags << comment_footer_links_wrapper(edit_links) if edit_links.any?
      tags << comment_footer_links_wrapper(create_links) if create_links.any?
      return if tags.none?

      safe_join(tags)
    end

    def task_comment_footer(object, comment)
      edit_links = task_comment_edit_links(object, comment)
      create_links = task_comment_create_links(object, comment)

      tags = []
      tags << comment_footer_links_wrapper(edit_links) if edit_links.any?
      tags << comment_footer_links_wrapper(create_links) if create_links.any?
      return if tags.none?

      safe_join(tags)
    end

    def comment_footer_links_wrapper(links)
      content_tag(:p, safe_join(links), class: 'comment-footer-links')
    end

    def task_comment_edit_links(object, comment)
      links = []

      if can?(:update, comment)
        links << link_to('edit', edit_task_task_comment_path(object, comment))
      end

      if can?(:destroy, comment)
        links << comment_links_divider
        links << task_comment_destroy_link(object, comment)
      end

      links
    end

    def task_comment_create_links(object, comment)
      links = []

      options = { source_task_id: object.to_param,
                  task_comment_id: comment.to_param }

      links << new_issue_link_selection(object.project, options)
      links << new_task_link_selection(object.project, options)

      links.flatten.unshift 'copy to '
    end

    def issue_comment_edit_links(object, comment)
      links = []

      if can?(:update, comment)
        links << link_to('edit', edit_issue_issue_comment_path(object, comment))
      end

      if can?(:destroy, comment)
        links << comment_links_divider
        links << issue_comment_destroy_link(object, comment)
      end

      links
    end

    def issue_comment_create_links(object, comment)
      links = []

      options = { source_issue_id: object.to_param,
                  issue_comment_id: comment.to_param }

      links << new_issue_link_selection(object.project, options)
      links << new_task_link_selection(object.project, options)

      links.flatten.unshift 'copy to '
    end

    def new_issue_link_selection(project, options)
      return unless can?(:create, Issue)

      if can?(:create, new_issue(project))
        new_issue_link(options.merge(project_id: project.id))
      else
        new_issue_link(options)
      end
    end

    def new_task_link_selection(project, options)
      return unless can?(:create, Task)

      if can?(:create, new_task(project))
        new_task_link(new_project_task_path(project, options))
      else
        new_task_link(new_projects_task_path(options))
      end
    end

    def new_issue_link(options)
      link_to('new issue', new_issue_path(options),
              data: { turbo_frame: '_top' })
    end

    def new_task_link(url)
      [comment_links_divider,
       link_to('new task', url, data: { turbo_frame: '_top' })]
    end

    def display_comment_footer?(comment)
      can?(:update, comment) || can?(:destroy, comment) || can?(:create, Issue)
    end

    def task_comment_destroy_link(object, comment)
      link_to 'delete',
              issue_issue_comment_path(object, comment),
              method: :delete, class: 'destroy-link',
              data: { turbo_method: :delete,
                      turbo_confirm: comment_destroy_confirm }
    end

    def issue_comment_destroy_link(object, comment)
      link_to 'delete',
              issue_issue_comment_path(object, comment),
              method: :delete, class: 'destroy-link',
              data: { turbo_method: :delete,
                      turbo_confirm: comment_destroy_confirm }
    end

    def comment_destroy_confirm
      'Are you sure you want to remove this comment?'
    end

    def comment_links_divider
      [' ', divider, ' ']
    end

    def comment_footer_class(comment)
      css_class = 'comment-footer '
      css_class +
        if can?(:update, comment) && can?(:create, Issue)
          'two-link-sets'
        else
          'one-link-set'
        end
    end
end
