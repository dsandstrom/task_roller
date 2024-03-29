# frozen_string_literal: true

module CategoriesHelper
  def category_tags(category)
    content_tag :p, class: 'category-tags' do
      concat visible_tag(category)
      concat internal_tag(category)
    end
  end

  def category_header(category)
    columns = [category_header_first_column(category),
               category_header_second_column(category)]
    content_for :header do
      concat breadcrumbs(category_breadcrumb_pages(category))
      concat content_tag(:div, safe_join(columns), class: 'columns')
      concat category_nav(category)
    end
  end

  def category_page?(category)
    pages = [category_path(category), category_tasks_path(category),
             category_issues_path(category), category_path(category),
             category_projects_path(category),
             archived_category_projects_path(category)]
    pages.any? { |path| current_page?(path) }
  end

  def category_index_header
    enable_page_title categories_heading

    content_for :header do
      concat content_tag(:h1, categories_heading)
      concat categories_nav
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
          'Categories &  Projects'
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
      content_tag :p, class: 'page-nav category-nav' do
        safe_join(navitize(category_nav_links(category)))
      end
    end

    def category_nav_links(category)
      [['Category', category_path(category)],
       ['Issues', category_issues_path(category)],
       ['Tasks', category_tasks_path(category)]]
    end

    def categories_nav
      content_tag :p, class: 'page-nav category-nav' do
        safe_join(navitize(categories_nav_links))
      end
    end

    def categories_nav_links
      return [] unless can?(:read, invisible_category) &&
                       Category.all_invisible.any?

      [['Categories', root_path],
       ['Archived Categories', archived_categories_path]]
    end

    def edit_category_link(category)
      edit_path = edit_category_path(category)
      return unless can?(:update, category) && !current_page?(edit_path)

      ['Category Settings', edit_path]
    end

    def invisible_category
      @invisible_category ||= Category.new(visible: false)
    end

    def invisible_project(category)
      category.projects.build(visible: false)
    end

    def category_breadcrumb_pages(category)
      pages = [['Categories', root_path]]
      unless category.visible?
        pages << ['Archived Categories', archived_categories_path]
      end
      pages
    end

    def category_header_first_column(category)
      url = category_path(category)

      content_tag :div, class: 'first-column' do
        concat content_tag(:h1, link_to_unless_current(category.name, url))
        concat category_tags(category)
        concat category_page_title(category)
      end
    end

    def category_header_second_column(category)
      buttons = edit_category_link(category)
      return if buttons.blank?

      buttons = navitize([buttons], class: 'button')
      content_tag :div, class: 'second-column' do
        content_tag :p, safe_join(buttons)
      end
    end
end
