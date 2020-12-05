# frozen_string_literal: true

module UsersHelper
  def user_header(user = nil)
    return new_user_header(user) unless user.persisted?

    link = link_to_unless_current(user.name_or_email, user)
    user_page_title(user)
    content_tag :header, class: 'user-header' do
      concat user_breadcrumbs
      concat content_tag(:h1, link)
      concat user_nav(user)
    end
  end

  def dashboard_nav
    links = [['Dashboard', root_path],
             ['Subscribed Issues', issue_subscriptions_path],
             ['Subscribed Tasks', task_subscriptions_path]]

    content_tag :p, class: 'user-nav' do
      safe_join(navitize(links), divider_with_spaces)
    end
  end

  def user_breadcrumbs
    @user_breadcrumbs ||= breadcrumbs([['Users', users_path]])
  end

  private

    def user_nav(user)
      content_tag :p, class: 'user-nav' do
        safe_join(navitize(user_nav_links(user)), divider_with_spaces)
      end
    end

    # TODO: rename Profile to Dashboard?
    def user_nav_links(user)
      links = [['Profile', user_path(user)],
               ['Reported Issues', user_issues_path(user)]]
      links << ['Created Tasks', user_tasks_path(user)] if user.tasks.any?

      if user.assignments.any?
        links << ['Assigned Tasks', user_assignments_path(user)]
      end
      return links unless can?(:update, user)

      links.append ['Options', edit_user_path(user), { class: 'destroy-link' }]
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
      content_tag :header, class: 'user-header' do
        concat user_breadcrumbs
        concat content_tag(:h1, heading)
      end
    end
end
