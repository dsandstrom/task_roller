# frozen_string_literal: true

module UsersHelper
  def user_header(user)
    return new_user_header(user) unless user.persisted?

    user_page_title(user)

    content_for :header do
      concat user_breadcrumbs
      concat user_header_content(user)
      concat user_nav(user)
    end
  end

  def user_inner_header(user, heading)
    user_page_title(user)

    content_for :header do
      concat user_breadcrumbs(user)
      concat content_tag(:h1, heading)
      concat user_edit_nav(user)
    end
  end

  def users_header
    enable_page_title 'Users'

    content_for :header do
      concat content_tag(:h1, 'Users')
      concat dashboard_nav
    end
  end

  def new_reporter
    @new_reporter ||= User.new(employee_type: 'Reporter')
  end

  def user_dropdown(user)
    options = { class: 'dropdown-menu user-dropdown',
                data: { link: 'user-dropdown-link' } }

    content_tag :div, options do
      concat dropdown_menu_user_container(user)
      concat dropdown_menu_logout_container
    end
  end

  private

    def user_heading_and_button(user)
      link = link_to_unless_current(user.name_or_email, user)
      button = link_to('Account Settings', edit_user_path(user),
                       class: 'button')

      content_tag :div, class: 'columns' do
        concat content_tag(:div, content_tag(:h1, link), class: 'first-column')
        concat content_tag(:div, button, class: 'second-column')
      end
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

    def new_user_header(user)
      heading =
        "New #{user.employee_type&.present? ? user.employee_type : 'User'}"
      content_for :header do
        concat user_breadcrumbs
        concat content_tag(:h1, heading)
      end
    end

    def dropdown_menu_user_container(user)
      content_tag :div, class: 'dropdown-menu-container' do
        concat content_tag(:span, user.email,
                           class: 'user-email dropdown-menu-title')
        concat safe_join(navitize(user_nav_links(user),
                                  class: 'button button-clear'))
      end
    end

    def dropdown_menu_logout_container
      content_tag :div, class: 'dropdown-menu-container' do
        safe_join(navitize(log_out_link))
      end
    end

    def log_out_link
      [['Log Out', destroy_user_session_path,
        { method: :delete, class: 'button button-warning button-clear' }]]
    end

    def user_breadcrumbs(user = nil)
      pages = [['Users', users_path]]
      pages.append([user.name_or_email, user_path(user)]) if user.present?
      breadcrumbs(pages)
    end

    def user_nav(user)
      content_tag :p, class: 'page-nav user-nav' do
        safe_join(navitize(user_nav_links(user)))
      end
    end

    def user_header_content(user)
      content_tag :main, class: 'header-content' do
        if can?(:edit, user)
          user_heading_and_button(user)
        else
          content_tag(:h1, link_to_unless_current(user.name_or_email, user))
        end
      end
    end

    def user_nav_links(user)
      links = [['Profile', user_path(user)],
               ['Reported Issues', user_issues_path(user)]]
      links << ['Created Tasks', user_tasks_path(user)] if user.tasks.any?
      return links if user.assignments.none?

      links << ['Assigned Tasks', user_assignments_path(user)]
    end
end
