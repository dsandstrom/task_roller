# frozen_string_literal: true

module CategoriesHelper
  def category_tags(category)
    content_tag :p, class: 'category-tags' do
      concat visible_tag(category)
      concat internal_tag(category)
    end
  end

  def category_header(category, options = {})
    content_tag :header, class: 'category-header' do
      content_tag :div, class: 'columns' do
        concat category_header_first_column(category)
        concat category_header_second_column(category, options)
      end
    end
  end

  def category_page?(category)
    pages = [category_path(category), category_tasks_path(category),
             category_issues_path(category), category_projects_path(category)]
    pages.any? { |path| current_page?(path) }
  end

  def category_index_header
    enable_page_title categories_heading

    content_tag :header, class: 'category-index-header' do
      concat content_tag(:h1, categories_heading)
      concat categories_nav if can?(:read, invisible_category)
    end
  end

  private

    def categories_heading
      @categories_heading ||=
        case params[:action]
        when 'archived'
          'Archived Categories'
        when 'new'
          'New Category'
        else
          'Categories'
        end
    end

    def categories_nav
      links =
        [['Active', categories_path],
         ['Archived', archived_categories_path, { class: 'secondary-link' }]]
      if can?(:create, Category)
        links << ['Add Category', new_category_path, { class: 'create-link' }]
      end

      content_tag :p, class: 'category-nav' do
        safe_join(navitize(links), divider_with_spaces)
      end
    end

    def category_page_title(category)
      title =
        case params[:controller]
        when 'issues'
          issues_page_title(category.name)
        when 'tasks'
          tasks_page_title(category.name)
        else
          categories_page_title(category)
        end
      enable_page_title title
    end

    def categories_page_title(category)
      if params[:action] == 'edit'
        "Edit Category: #{category.name}"
      else
        "Category: #{category.name}"
      end
    end

    def category_nav(category)
      content_tag :p, class: 'category-nav' do
        safe_join(navitize(category_nav_links(category)), divider_with_spaces)
      end
    end

    def category_nav_links(category)
      [['Category', category_projects_path(category)],
       ['Issues', category_issues_path(category)],
       ['Tasks', category_tasks_path(category)],
       archived_projects_link(category), new_project_link(category),
       edit_category_link(category)].compact
    end

    def archived_projects_link(category)
      return unless category.visible? && can?(:read, invisible_category) &&
                    category.projects.all_invisible.any?

      ['Archived Projects', archived_category_projects_path(category),
       { class: 'secondary-link' }]
    end

    def edit_category_link(category)
      return unless can?(:update, category)

      ['Settings', edit_category_path(category), { class: 'destroy-link' }]
    end

    def new_project_link(category)
      return unless can?(:update, new_project(category))

      ['New Project', new_category_project_path(category),
       { class: 'create-link' }]
    end

    def invisible_category
      @invisible_category ||= Category.new(visible: false)
    end

    def category_breadcrumb_pages(category)
      if category.visible?
        [['Categories', categories_path]]
      else
        [['Archived Categories', archived_categories_path]]
      end
    end

    def category_header_first_column(category)
      url = category_projects_path(category)

      content_tag :div, class: 'first-column' do
        concat breadcrumbs(category_breadcrumb_pages(category))
        concat content_tag(:h1, link_to_unless_current(category.name, url))
        concat category_tags(category)
        concat category_nav(category)
        concat category_page_title(category)
      end
    end

    def category_header_second_column(category, options)
      return unless options[:subscriptions].present?

      buttons = options[:subscriptions].map do |s|
        content = render(s, category: category)
        next if content == "\n"

        content_tag :p, content
      end.compact
      return unless buttons&.any?

      content_tag :div, class: 'second-column' do
        safe_join(buttons)
      end
    end
end
