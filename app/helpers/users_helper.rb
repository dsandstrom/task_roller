# frozen_string_literal: true

module UsersHelper
  def user_header(user = nil)
    return new_user_header(user) unless user.persisted?

    link = link_to_unless_current(user.name_or_email, user)
    user_page_title(user)

    content_for :header do
      concat user_breadcrumbs
      concat content_tag(:h1, link)
      concat user_nav(user)
    end
  end

  def users_header
    enable_page_title 'Users'

    content_for :header do
      concat content_tag(:h1, 'Users')
      concat dashboard_nav
    end
  end

  def dashboard_nav
    links = [['Subscriptions', root_path], ['Categories', categories_path],
             ['Users', users_path]]
    links << ['App Setup', issue_types_path] if can?(:read, IssueType)

    content_tag :p, class: 'page-nav user-nav' do
      safe_join(navitize(links))
    end
  end

  def user_breadcrumbs
    @user_breadcrumbs ||= breadcrumbs([['Users', users_path]])
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

    def user_nav(user)
      content_tag :p, class: 'page-nav user-nav' do
        safe_join(navitize(user_nav_links(user)))
      end
    end

    def user_nav_links(user)
      links = [['Profile', user_path(user)],
               ['Reported Issues', user_issues_path(user)]]
      links << ['Created Tasks', user_tasks_path(user)] if user.tasks.any?

      if user.assignments.any?
        links << ['Assigned Tasks', user_assignments_path(user)]
      end
      return links unless can?(:update, user)

      links.append ['Settings', edit_user_path(user)]
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
end
