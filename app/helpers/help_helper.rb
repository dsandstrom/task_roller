# frozen_string_literal: true

module HelpHelper
  def help_nav
    links = [['Issue Types', issue_types_help_path],
             ['User Types', user_types_help_path],
             ['Workflows', workflows_help_path]]

    content_tag :p, class: 'help-nav' do
      safe_join(navitize(links), divider_with_spaces)
    end
  end

  def help_header(heading)
    enable_page_title "#{heading} Help Page"
    content_tag :header, class: 'help-header' do
      concat content_tag :h1, 'Help Pages'
      concat content_tag :h2, heading
      concat help_nav
    end
  end
end
