# frozen_string_literal: true

module UsersHelper
  def user_header(user = nil)
    content_tag :header, class: 'user-header' do
      concat breadcrumbs([['Users', users_path]])
      if user.present?
        link = link_to_unless_current(user.name_or_email, user)
        concat content_tag(:h1, link)
        concat user_nav(user)
        concat user_page_title(user)
      end
    end
  end

  private

    def user_nav(user)
      content_tag :p, class: 'user-nav' do
        safe_join(user_nav_links(user), divider_with_spaces)
      end
    end

    # TODO: rename Profile to Dashboard?
    def user_nav_links(user)
      links = user_base_nav_links(user)
      if current_user && user.id == current_user.id
        links <<
          link_to_unless_current('Subscribed Issues', issue_subscriptions_path)
        links <<
          link_to_unless_current('Subscribed Tasks', task_subscriptions_path)
      end
      links << user_main_nav_links(user)
      links
    end

    def user_base_nav_links(user)
      links = [link_to_unless_current('Profile', user_path(user))]
      return links unless can?(:update, user)

      links << link_to_unless_current('Options', edit_user_path(user))
      links
    end

    def user_main_nav_links(user)
      [link_to_unless_current('Reported Issues', user_issues_path(user)),
       link_to_unless_current('Created Tasks', user_tasks_path(user)),
       link_to_unless_current('Assigned Tasks', user_assignments_path(user))]
    end

    def user_page_title(user)
      name = user.name_or_email
      enable_page_title page_title_content(name)
    end

    def page_title_content(name) # rubocop:disable Metrics/MethodLength
      case params[:controller]
      when 'issues'
        issues_page_title(name)
      when 'tasks'
        "Tasks from #{name}"
      when 'assignments'
        tasks_page_title(name)
      when 'task_subscriptions'
        'Subscribed Tasks'
      when 'issue_subscriptions'
        'Subscribed Issues'
      else
        users_page_title(name)
      end
    end

    def users_page_title(name)
      if params[:action] == 'edit'
        "Edit User: #{name}"
      else
        "User: #{name}"
      end
    end
end
