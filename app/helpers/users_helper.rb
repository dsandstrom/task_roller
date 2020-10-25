# frozen_string_literal: true

module UsersHelper
  def user_header(user = nil)
    content_tag :header, class: 'user-header' do
      concat breadcrumbs([['Users', users_path]])
      if user.present?
        link = link_to_unless_current(user.name_or_email, user)
        concat content_tag(:h1, link)
        concat user_nav(user)
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
      [link_to_unless_current('Profile', user_path(user)),
       link_to_unless_current('Reported Issues', user_issues_path(user)),
       link_to_unless_current('Created Tasks', user_tasks_path(user)),
       link_to_unless_current('Assigned Tasks',
                              user_task_assignments_path(user))]
    end

    def divider_with_spaces
      safe_join([' ', divider, ' '])
    end
end
