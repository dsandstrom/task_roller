# frozen_string_literal: true

module NavigationsHelper
  def dashboard_nav
    links = [['Subscriptions', root_path], ['Categories', categories_path],
             ['Users', users_path]]
    links << ['App Setup', issue_types_path] if can?(:read, IssueType)

    content_tag :p, class: 'page-nav user-nav' do
      safe_join(navitize(links))
    end
  end

  def user_side_nav(user)
    links = [['Basic', edit_user_path(user)],
             ['Update Name', edit_user_path(user, anchor: 'name')]]
    if current_user.id == user.id
      links = add_current_user_links(user, links)
    elsif can?(:promote, user)
      links = add_admin_links(user, links)
    end

    content_tag :p, class: 'side-nav user-nav' do
      safe_join(navitize(links))
    end
  end

  private

    def add_current_user_links(user, links)
      links << ['Connections', edit_user_path(user, anchor: 'connections')]
      links << ['Advanced', edit_user_registration_path]
      if respond_to?(:edit_user_registration_path)
        links <<
          ['Change Password', edit_user_registration_path(anchor: 'password')]
      end
      return links unless can?(:cancel, user)

      links << ['Cancel Account', edit_user_registration_path(anchor: 'cancel')]
    end

    def add_admin_links(user, links)
      if user.employee?
        links << ['Advanced', edit_user_employee_type_path(user)]
        links << ['User Level',
                  edit_user_employee_type_path(user, anchor: 'employee')]
        links << ['Cancel Account',
                  edit_user_employee_type_path(user, anchor: 'cancel')]
      else
        links << ['User Level', new_user_employee_type_path(user)]
      end
      links
    end
end
