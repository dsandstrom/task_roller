# frozen_string_literal: true

module CategoriesHelper
  def category_tags(category)
    content_tag :p, class: 'category-tags' do
      concat visible_tag(category)
      concat internal_tag(category)
    end
  end

  def category_header(category)
    url = category_projects_path(category)

    content_tag :header, class: 'category-header' do
      concat breadcrumbs([['Categories', categories_path]])
      concat content_tag(:h1, link_to_unless_current(category.name, url))
      concat category_tags(category)
      concat category_nav(category)
      concat category_page_title(category)
    end
  end

  def category_page?(category)
    pages = [category_path(category), category_tasks_path(category),
             category_issues_path(category)]
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
        if params[:action] == 'archived'
          'Archived Categories'
        else
          'Categories'
        end
    end

    def categories_nav
      links = [['Active Categories', categories_path],
               ['Archives', archived_categories_path]]

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
      links =
        [['Category', category_projects_path(category)],
         ['Issues', category_issues_path(category)],
         ['Tasks', category_tasks_path(category)]]
      return links unless can?(:update, category)

      links.append(edit_category_link(category))
    end

    def edit_category_link(category)
      ['Settings', edit_category_path(category), { class: 'destroy-link' }]
    end

    def invisible_category
      @invisible_category ||= Category.new(visible: false)
    end
end
