# frozen_string_literal: true

module NavigationsHelper
  def root_nav
    links = [['Subscriptions', subscriptions_path], ['Categories', root_path]]
    links << ['App Setup', issue_types_path] if can?(:read, IssueType)

    content_tag :p, class: 'page-nav user-nav' do
      safe_join(navitize(links))
    end
  end

  def user_edit_nav(user)
    links = [['Name & Connections', edit_user_path(user)]]
    if current_user.id == user.id
      links = add_current_user_links(user, links)
    elsif can?(:promote, user)
      links = add_admin_links(user, links)
    end

    content_tag :p, class: 'page-nav user-nav' do
      safe_join(navitize(links))
    end
  end

  private

    def add_current_user_links(user, links)
      return links unless respond_to?(:edit_user_registration_path)

      title = 'Password'
      title += ' & Status' if can?(:cancel, user)
      links << [title, edit_user_registration_path]
    end

    def add_admin_links(user, links)
      links <<
        if user.employee?
          ['Account Level', edit_user_employee_type_path(user)]
        else
          ['Account Level', new_user_employee_type_path(user)]
        end
    end
end
